defmodule SalesReg.Store do
  @moduledoc """
  The Store context.
  """
  use SalesRegWeb, :context
  alias Dataloader.Ecto, as: DataloaderEcto

  use SalesReg.Context, [
    Product,
    Category,
    Tag,
    Invoice
  ]

  alias Absinthe.Relay.Connection
  alias Ecto.UUID

  defdelegate category_image(category), to: Category
  defdelegate get_product_name(product), to: Product
  defdelegate get_product_share_link(product), to: Product

  def data do
    DataloaderEcto.new(Repo, query: &query/2)
  end

  def query(queryable, _) do
    queryable
  end

  def load_categories(%{categories: []}), do: []

  def load_categories(%{categories: categories}) do
    load_categories(%{"categories" => categories})
  end

  def load_categories(%{"categories" => []}) do
    []
  end

  def load_categories(%{"categories" => categories_ids}) do
    all_categories(categories_ids)
  end

  def load_categories(_), do: []

  def load_tags(%{"tags" => tag_names, "company_id" => company_id}) do
    gen_company_tags(tag_names, [], company_id)
  end

  def load_tags(%{tags: tag_names, company_id: company_id}) do
    gen_company_tags(tag_names, [], company_id)
  end

  def load_tags(_), do: []

  def load_products(company_id, query) do
    query_regex = "%" <> query <> "%"

    query =
      from(p in Product,
        where: ilike(p.title, ^query_regex),
        where: p.company_id == ^company_id,
        order_by: [asc: :p.title()],
        select: p
      )
      |> Repo.all()
  end

  def load_products(company_id, query, args) do
    query_regex = "%" <> query <> "%"

    query =
      from(p in Product,
        where: ilike(p.title, ^query_regex),
        where: p.company_id == ^company_id,
        order_by: [desc: :updated_at],
        select: p
      )

    query
    |> Connection.from_query(&Repo.all/1, args)
  end

  def load_related_products(company_id, product_id, limit \\ 12, offset \\ 0) do
    {:ok, company_id} = Ecto.UUID.dump(company_id)
    {:ok, product_id} = Ecto.UUID.dump(product_id)
    params = [company_id, product_id, product_id, limit, offset]

    query = """
      SELECT  *
      FROM    products AS prods
      WHERE   prods.company_id = $1::uuid
      AND
        ARRAY(
          SELECT  tags.name
          FROM    tags tags
          JOIN    products_tags
          ON      products_tags.tag_id  = tags.id
          WHERE   products_tags.product_id = $2::uuid
        )
        &&
        ARRAY(
          SELECT  tags.name
          FROM    tags tags
          JOIN    products_tags
          ON      products_tags.tag_id = tags.id
          WHERE   products_tags.product_id = prods.id
        )

      ORDER BY (
        array_length(
          ARRAY(
            SELECT UNNEST(
              ARRAY(
                SELECT  tags.name
                FROM    tags tags
                JOIN    products_tags
                ON      products_tags.tag_id  = tags.id
                WHERE   products_tags.product_id = $3::uuid
              )
            )
            INTERSECT
            SELECT UNNEST(
              ARRAY(
                SELECT  tags.name
                FROM    tags tags
                JOIN    products_tags
                ON      products_tags.tag_id = tags.id
                WHERE   products_tags.product_id = prods.id
              )
            )
          ), 1)
        ) DESC
      LIMIT   $4::int
      OFFSET  $5::int
    """

    Repo.execute_and_load(query, params, Product)
  end

  def list_featured_items(company_id) do
    Product
    |> where([p], p.is_featured == true)
    |> where([p], p.company_id == ^company_id)
    |> select([p], {p.name, p.is_top_rated_by_merchant})
    |> order_by([p], asc: p.is_featured)
    |> Repo.all()
  end

  def list_top_rated_items(company_id) do
    Product
    |> where([p], p.is_top_rated_by_merchant == true)
    |> where([p], p.company_id == ^company_id)
    |> select([p], {p.name, p.is_top_rated_by_merchant})
    |> order_by([p], asc: p.is_top_rated_by_merchant)
    |> Repo.all()
  end

  # PRODUCT INVENTORY
  def update_product_inventory(:increment, order_items) when is_list(order_items) do
    order_items =
      order_items
      |> Enum.map(fn order_item ->
        if order_item.product_id do
          increment_product_sku(order_item.product_id, order_item.quantity)
        end

        order_item
      end)

    product = get_product(Enum.random(order_items).product_id)
    create_restock_notification(order_items, product)
  end

  def update_product_inventory(:decrement, order_items) when is_list(order_items) do
    order_items
    |> Enum.map(fn order_item ->
      if order_item.product_id do
        decrement_product_sku(order_item.product_id, order_item.quantity)
      end

      order_item
    end)
  end

  def create_restock_notification(order_items, product) do
    %{
      company_id: product.company_id,
      actor_id: product.user_id,
      message: "#{Enum.count(order_items)} products were restocked",
      notification_items: gen_restock_notification_items(order_items)
    }
    |> Notifications.create_notification({:product, ""}, :restock)
  end

  def create_product(params) do
    product_params = Map.get(params, :product)
    Product.changeset(%Product{}, product_params)
  end

  def update_product_details(id, params) do
    id
    |> get_product()
    |> update_product(params)
  end

  # WEBSTORE REQUIRED METHODS
  def home_categories(company_id) do
    Repo.all(
      from(c in Category,
        join: pc in "products_categories",
        on: pc.category_id == c.id,
        where: c.company_id == ^company_id,
        limit: 10,
        distinct: true,
        preload: [:products]
      )
    )
  end

  def paginated_categories(company_id) do
    Repo.all(
      from(c in Category,
        where: c.company_id == ^company_id,
        limit: 15,
        preload: [:products]
      )
    )
  end

  def search_company_categories(company_id, query, args) do
    query_regex = "%" <> query <> "%"

    query =
      from(c in Category,
        join: pc in "products_categories",
        on: pc.category_id == c.id,
        where: c.company_id == ^company_id,
        where: ilike(c.title, ^query_regex),
        order_by:
          fragment(
            "ts_rank(to_tsvector(?), plainto_tsquery(?)) DESC",
            c.title,
            ^query
          ),
        distinct: c.id,
        preload: [:products]
      )

    query
    |> Connection.from_query(&Repo.all/1, args)
  end

  def category_products(category_id, page) do
    {:ok, category_id} = UUID.dump(category_id)

    query =
      from(p in Product,
        join: pc in "products_categories",
        on: pc.category_id == ^category_id,
        where: pc.product_id == p.id,
        select: p
      )

    Repo.paginate(query, page: page)
  end

  def filter_webstore_products(company_id, filter_params) do
    query =
      from(p in Product,
        where: p.company_id == ^company_id,
        select: p
      )

    query
    |> Repo.paginate(page: Map.get(filter_params, :page))
  end

  def list_featured_products(company_id) do
    query =
      from(p in Product,
        where: p.company_id == ^company_id and p.is_featured == true,
        select: p,
        limit: 10
      )

    query
    |> Repo.all()
    |> Enum.map(&store_item_preloads(&1))
    |> List.flatten()
  end

  def random_top_rated_product(company_id) do
    query =
      from(p in Product,
        where: p.company_id == ^company_id and p.is_top_rated_by_merchant == true,
        order_by: fragment("RANDOM()")
      )

    query
    |> Repo.all()
    |> Enum.map(&store_item_preloads(&1))
    |> Enum.at(0)
  end

  def list_top_rated_products(company_id) do
    Product
    |> where([p], p.company_id == ^company_id)
    |> where([p], p.is_top_rated_by_merchant == true)
    |> select([p], [p])
    |> limit(10)
    |> Repo.all()
    |> Enum.map(&store_item_preloads(&1))
    |> List.flatten()
  end

  def calculate_store_item_stars(%{stars: []}), do: 0

  def calculate_store_item_stars(%{stars: stars}) do
    total_stars =
      stars
      |> Enum.map(& &1.value)
      |> Enum.sum()

    no_of_time_starred = Enum.count(stars)
    total_stars / no_of_time_starred
  end

  def get_product_by_slug(slug) do
    Product
    |> Repo.get_by(slug: slug)
  end

  def get_category_by_slug(slug) do
    Category
    |> Repo.get_by(slug: slug)
  end

  def get_product_name_by_id(id) do
    Product
    |> Repo.get(id)
    |> Store.get_product_name()
  end

  defp add_type_field(products) do
    Enum.map(products, fn prod ->
      %{prod | name: get_product_name(prod)}
      |> Map.put_new(:type, "Product")
    end)
  end

  defp all_categories(categories_ids) do
    Repo.all(
      from(
        c in Category,
        where: c.id in ^categories_ids
      )
    )
  end

  defp gen_company_tags([], acc, _company_id) do
    acc
  end

  defp gen_company_tags([tag_name | tail], acc, company_id) do
    gen_company_tags(tail, acc ++ [tag_struct(tag_name, company_id)], company_id)
  end

  defp tag_struct(tag_name, company_id) do
    tag =
      Tag
      |> where([t], t.name == ^tag_name)
      |> where([t], t.company_id == ^company_id)
      |> Repo.one()

    case tag do
      %Tag{} ->
        tag

      _ ->
        tag_params = %{
          name: tag_name,
          company_id: company_id
        }

        {:ok, tag} = Store.add_tag(tag_params)
        tag
    end
  end

  # PRODUCT INVENTORY
  defp increment_product_sku(product_id, quantity) do
    product = get_product_for_inventory(product_id)
    params = %{sku: "#{product.sku + quantity}"}

    update_product(product, params)
  end

  defp decrement_product_sku(product_id, quantity) do
    product = get_product_for_inventory(product_id)
    params = parse_product_params(product, %{sku: "#{product.sku - quantity}"})

    update_product(product, params)
  end

  defp get_product_for_inventory(product_id) do
    get_product(product_id)
  end

  defp store_item_preloads(item) do
    Repo.preload(item, [:tags, :reviews, :stars, :categories])
  end

  defp gen_restock_notification_items(order_items) do
    Enum.map(order_items, fn order_item ->
      product = get_product(order_item.product_id)
      product_sku = String.to_integer(product.sku)
      quantity = String.to_integer(order_item.quantity)

      %{
        item_type: "product",
        item_id: order_item.product_id,
        current: "#{product_sku - quantity}",
        changed_to: product_sku
      }
    end)
  end
end
