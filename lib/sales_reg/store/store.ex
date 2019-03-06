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
    ProductGroup,
    Option,
    OptionValue,
    Invoice
  ]

  alias Ecto.UUID

  defdelegate category_image(category), to: Category
  defdelegate get_product_name(product), to: Product
  defdelegate get_product_share_link(product), to: Product
  defdelegate product_name_based_on_visual_options(product), to: Product

  def data do
    DataloaderEcto.new(Repo, query: &query/2)
  end

  def query(queryable, _) do
    queryable
  end

  def insert_default_options(company_id) do
    [
      %{name: "Size", company_id: company_id},
      %{name: "Color", company_id: company_id, is_visual: "yes"},
      %{name: "Weight", company_id: company_id},
      %{name: "Height", company_id: company_id}
    ]
    |> Enum.map(&Repo.insert(Option.changeset(%Option{}, &1)))
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

    ProductGroup
    |> join(:inner, [pg], p in assoc(pg, :products))
    |> preload([pg, p], products: p)
    |> where([pg, p], pg.company_id == ^company_id)
    |> where([pg, p], ilike(pg.title, ^query_regex))
    |> order_by([pg, p], asc: [pg.title])
    |> select([pg, p], [pg])
    |> Repo.all()
    |> Enum.map(fn [prod_group] ->
      add_type_field = fn products ->
        Enum.map(products, fn prod ->
          %{prod | name: get_product_name(prod)}
          |> Map.put_new(:type, "Product")
        end)
      end

      add_type_field.(prod_group.products)
    end)
    |> List.flatten()
  end

  def load_products(company_id, query, args) do
    query_regex = "%" <> query <> "%"

    from(p in Product,
      join: pg in ProductGroup,
      on: p.product_group_id == pg.id,
      where: ilike(pg.title, ^query_regex),
      where: p.company_id == ^company_id,
      order_by: [desc: :updated_at],
      select: p
    )
    |> Absinthe.Relay.Connection.from_query(&Repo.all/1, args)
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
    Enum.map(order_items, fn order_item ->
      if order_item.product_id do
        increment_product_sku(order_item.product_id, order_item.quantity)
      end

      order_item
    end)

    product = get_product(Enum.random(order_items).product_id)
    create_restock_notification(order_items, product)
  end

  def update_product_inventory(:decrement, order_items) when is_list(order_items) do
    Enum.map(order_items, fn order_item ->
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
      element_data: "#{Enum.count(order_items)} products were restocked",
      notification_items: gen_restock_notification_items(order_items)
    }
    |> Notifications.create_notification({:product, ""}, :restock)
  end

  # PRODUCT VARIANT

  # EXPECTED PRODUCT PARAMS
  # product_params
  # %{
  #   product_group_id: nil,
  #   product_group_title: "",
  #   product: %{
  #     id: ""
  #     decription: "",
  #     featured_image: "",
  #     name: "",
  #     sku: "",
  #     minimum_sku: "",
  #     price: "",
  #     images: [],
  #     option_values: [
  #     %{
  #       option_id: "ffddf43334", # basically the ID of the option
  #       name: "XL"
  #     },
  #     %{option_id: "ddeyu84djd09393d", name: "Red"}
  #   ]
  #   },
  # }

  # create new product with no options
  # 1 create product group
  # 2 create product, with product_group association
  def create_product(
        %{
          product_group_title: product_group_title,
          product: %{option_values: []}
        } = params
      ) do
    product_params = Map.get(params, :product)

    product_grp_params = %{
      "title" => product_group_title,
      "option_ids" => [],
      "company_id" => params.company_id
    }

    opts =
      Multi.new()
      |> Multi.insert(:insert_product_grp, product_group_changeset(product_grp_params))
      |> Multi.insert(
        :product,
        fn %{insert_product_grp: product_grp} ->
          product_params =
            product_params
            |> Map.put(:product_group_id, product_grp.id)
            |> Map.put(:title, product_grp.title)

          Product.changeset(%Product{}, product_params)
        end
      )

    case Repo.transaction(opts) do
      {:ok, %{product: product}} -> {:ok, product}
      {:error, _failed_operation, _failed_value, changeset} -> {:error, changeset}
    end
  end

  # create new product from existing product group
  def create_product(%{product_group_id: id} = params) do
    # preload and get the current options associated with the product group
    %ProductGroup{options: current_associated_options} = product_grp = get_product_grp(id)
    add_product_to_existing(current_associated_options, params, product_grp)
  end

  # create new product with options and no existing product group
  # 1 create a product_group, add options association
  # 2 insert product, with option values association and product_group
  def create_product(%{product_group_title: product_group_title} = params) do
    options_values =
      params
      |> Map.get(:product)
      |> Map.get(:option_values, [])

    option_ids = get_option_ids_from_option_values(options_values)
    product_params = Map.get(params, :product)

    product_grp_params = %{
      "title" => product_group_title,
      "option_ids" => option_ids,
      "company_id" => params.company_id
    }

    opts =
      Multi.new()
      |> Multi.insert(
        :insert_product_grp,
        product_group_changeset(product_grp_params)
      )
      |> Multi.insert(
        :product,
        fn %{insert_product_grp: product_grp} ->
          product_params =
            product_params
            |> Map.put(:product_group_id, product_grp.id)
            |> Map.put(:title, product_grp.title)

          Product.changeset(%Product{}, product_params)
        end
      )

    case Repo.transaction(opts) do
      {:ok, %{product: product}} ->
        {:ok, product}

      {:error, _failed_operation, failed_value, _changeset} ->
        {:error, failed_value}
    end
  end

  # update product details -> use context

  # update product group options -> use context
  def update_product_group_options(%{id: id, options: new_option_ids}) do
    # preload and get the current options associated with the product group
    %ProductGroup{options: current_associated_options, company_id: company_id} =
      product_grp = get_product_grp(id)

    product_grp_params = %{
      "option_ids" => new_option_ids
    }

    # delete irrelevant option values associated with options disconnected from the product group
    option_values_to_delete =
      current_associated_options
      |> compare_and_get_disconnected_options(new_option_ids)
      |> option_values_of_disconnected_options()

    # create new option values params based on option_ids
    # list all product associated to product_group
    new_option_values =
      current_associated_options
      |> compare_and_get_unique_new_options(new_option_ids)
      |> build_option_values(company_id)

    opts =
      Multi.new()
      |> Multi.update(
        :update_product_grp,
        product_group_changeset(product_grp, product_grp_params)
      )
      |> Multi.delete_all(:delete_option_values, option_values_to_delete)

      # add option_values to each of the products
      # update all products
      |> Multi.run(
        :update_all_associated_product_option_values,
        fn _repo, _multi ->
          {:ok, update_product_group_associated_product_option_values(new_option_values, id)}
        end
      )

    case Repo.transaction(opts) do
      {:ok, %{update_product_grp: update_product_grp}} -> {:ok, update_product_grp}
      {:error, _failed_operation, _failed_value, changeset} -> {:error, changeset}
    end
  end

  def update_product_details(id, params) do
    product = get_product(id, preload: [:product_group])

    params =
      params
      |> Map.put(:title, product.product_group.title)
      |> Map.put(:product_group_id, product.product_group.id)

    update_product(product, params)
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
    |> Absinthe.Relay.Connection.from_query(&Repo.all/1, args)
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
    from(p in Product,
      where: p.company_id == ^company_id,
      select: p
    )
    |> distinct_visual_variants()
    |> Repo.paginate(page: Map.get(filter_params, :page))
  end

  def list_featured_products(company_id) do
    from(p in Product,
      where: p.company_id == ^company_id and p.is_featured == true,
      select: p,
      limit: 10
    )
    |> distinct_visual_variants()
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

    Repo.all(query)
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
    quantity = String.to_integer(quantity)
    product_sku = String.to_integer(product.sku)

    params = parse_product_params(product, %{sku: "#{product_sku + quantity}"})

    update_product(product, params)
  end

  defp decrement_product_sku(product_id, quantity) do
    product = get_product_for_inventory(product_id)
    quantity = String.to_integer(quantity)
    product_sku = String.to_integer(product.sku)

    params = parse_product_params(product, %{sku: "#{product_sku - quantity}"})

    update_product(product, params)
  end

  defp get_product_for_inventory(product_id) do
    get_product(product_id, preload: [:product_group, :option_values])
  end

  defp parse_product_params(product, params) do
    params
    |> Map.put(:title, product.product_group.title)
    |> Map.put(:product_group_id, product.product_group.id)
    |> Map.put(:option_values, Enum.map(product.option_values, &transform_option_value(&1)))
  end

  defp transform_option_value(option_value) do
    option_value = Map.from_struct(option_value)

    %{
      name: option_value.name,
      company_id: option_value.company_id,
      option_id: option_value.option_id
    }
  end

  ## if the product group doesn't have options already,
  ##     1 update product group options association
  ##     2 update product with option values association
  defp add_product_to_existing([], params, product_grp) do
    # get the options from params
    options_values =
      params
      |> Map.get(:product)
      |> Map.get(:option_values, [])

    new_option_ids = get_option_ids_from_option_values(options_values)

    product_params = Map.get(params, :product)

    product_grp_params = %{
      "title" => Map.get(params, :product_group_title),
      "option_ids" => new_option_ids,
      "company_id" => params.company_id
    }

    opts =
      Multi.new()
      |> Multi.update(
        :update_product_grp,
        product_group_changeset(product_grp, product_grp_params)
      )
      |> Multi.run(:get_product, fn _repo, _params ->
        product_id = Map.get(product_params, :id)
        {:ok, Repo.get!(Product, product_id)}
      end)
      |> Multi.update(
        :product,
        fn %{update_product_grp: product_grp, get_product: product} ->
          product_params =
            product_params
            |> Map.put(:product_group_id, product_grp.id)
            |> Map.put(:title, product_grp.title)

          Product.changeset(product, product_params)
        end
      )

    case Repo.transaction(opts) do
      {:ok, %{product: product}} -> {:ok, product}
      {:error, _failed_operation, _failed_value, changeset} -> {:error, changeset}
    end
  end

  #  if the product group has options already, we create a new product
  #      1 insert the product, with option values association
  defp add_product_to_existing(_options, params, product_grp) do
    product_params =
      params
      |> Map.get(:product)
      |> Map.put(:product_group_id, product_grp.id)
      |> Map.put(:title, product_grp.title)

    add_product(product_params)
  end

  defp product_group_changeset(%ProductGroup{} = schema, params) do
    ProductGroup.changeset(schema, params)
  end

  defp product_group_changeset(params) do
    ProductGroup.changeset(%ProductGroup{}, params)
  end

  def load_product_grp_options(%{"option_ids" => []}), do: []

  def load_product_grp_options(%{"option_ids" => option_ids}) do
    Repo.all(from(opt in Option, where: opt.id in ^option_ids))
  end

  defp get_option_ids_from_option_values([]), do: []

  defp get_option_ids_from_option_values(options_values) do
    Enum.map(options_values, & &1.option_id)
  end

  defp get_product_grp(id), do: get_product_group(id) |> Repo.preload(:options)

  defp compare_and_get_disconnected_options([], _new_options_ids), do: []

  defp compare_and_get_disconnected_options(current_options_structs, new_options_ids) do
    options_ids = Enum.map(current_options_structs, & &1.id)
    MapSet.difference(MapSet.new(options_ids), MapSet.new(new_options_ids)) |> MapSet.to_list()
  end

  defp compare_and_get_unique_new_options(current_options_structs, new_options_ids) do
    options_ids = Enum.map(current_options_structs, & &1.id)
    MapSet.difference(MapSet.new(new_options_ids), MapSet.new(options_ids)) |> MapSet.to_list()
  end

  defp build_option_values(option_ids, company_id) do
    Enum.map(option_ids, fn id ->
      %{
        option_id: id,
        name: "_",
        company_id: company_id
      }
    end)
  end

  defp update_product_group_associated_product_option_values(new_option_values, product_group_id) do
    Product
    |> where([p], p.product_group_id == ^product_group_id)
    |> preload([p], [:option_values, :product_group])
    |> Repo.all()
    |> Enum.map(fn product ->
      product_changeset =
        Product.changeset(product, %{
          option_values: parse_product_option_values(product.option_values, new_option_values),
          title: product.product_group.title,
          product_group_id: product.product_group.id
        })

      Repo.update(product_changeset)
    end)
  end

  defp parse_product_option_values(current_option_values, new_option_values) do
    current_option_values
    |> Enum.map(&%{name: &1.name, option_id: &1.option_id, company_id: &1.company_id})
    |> Enum.concat(new_option_values)
  end

  defp option_values_of_disconnected_options(options_ids) do
    from(option_value in OptionValue, where: option_value.option_id in ^options_ids)
  end

  defp store_item_preloads(item) do
    Repo.preload(item, [:tags, :reviews, :stars, :categories])
  end

  defp distinct_visual_variants(query) do
    from(p in query,
      distinct:
        fragment(
          "CASE

          WHEN array_length(ARRAY(SELECT to_jsonb(row(option_id, name, ?)) FROM option_values WHERE option_values.product_id = ? AND (SELECT is_visual FROM options WHERE options.id = option_id) = ?), 1) > 0

          THEN ARRAY(SELECT to_jsonb(row(option_id, name, ?)) FROM option_values WHERE option_values.product_id = ? AND (SELECT is_visual FROM options WHERE options.id = option_values.option_id) = ?)


          WHEN array_length(ARRAY(SELECT to_jsonb(row(option_id, ?)) FROM option_values WHERE option_values.product_id = ? AND (SELECT is_visual FROM options WHERE options.id = option_id) = ?), 1) > 0

          THEN ARRAY(SELECT to_jsonb(row(option_id, ?)) FROM option_values WHERE option_values.product_id = ? AND (SELECT is_visual FROM options WHERE options.id = option_values.option_id) = ?)

          ELSE ARRAY(SELECT to_jsonb(row(slug, id)) FROM products WHERE products.id = ?)

          END",
          p.product_group_id,
          p.id,
          "yes",
          p.product_group_id,
          p.id,
          "yes",
          p.product_group_id,
          p.id,
          "no",
          p.product_group_id,
          p.id,
          "no",
          p.id
        )
    )
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
