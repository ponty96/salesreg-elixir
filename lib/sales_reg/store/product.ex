defmodule SalesReg.Store.Product do
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Store.Category
  alias SalesReg.Repo
  alias SalesReg.Store
  alias SalesReg.Business

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "products" do
    field(:description, :string)
    field(:name, :string)
    field(:sku, :string)
    field(:minimum_sku, :string)
    field(:cost_price, :string)
    field(:price, :string)
    field(:featured_image, :string)
    field(:images, {:array, :string})
    field(:is_featured, :boolean)
    field(:is_top_rated_by_merchant, :boolean)

    field(:slug, :string)
    field(:title, :string, virtual: true)

    belongs_to(:company, SalesReg.Business.Company)
    belongs_to(:user, SalesReg.Accounts.User)

    has_many(:items, SalesReg.Order.Item)
    has_many(:reviews, SalesReg.Order.Review)
    has_many(:stars, SalesReg.Order.Star)

    many_to_many(
      :categories,
      Category,
      join_through: "products_categories",
      on_replace: :delete
    )

    many_to_many(:tags, Store.Tag,
      join_through: "products_tags",
      on_replace: :delete
    )

    has_many(:option_values, Store.OptionValue, on_replace: :delete)

    belongs_to(:product_group, Store.ProductGroup)

    timestamps()
  end

  @fields [
    :description,
    :images,
    :is_featured,
    :is_top_rated_by_merchant,
    :name,
    :slug,
    :title
  ]

  @required_fields [
    :price,
    :company_id,
    :user_id,
    :sku,
    :minimum_sku,
    :featured_image,
    :product_group_id
  ]
  @doc false
  def changeset(product, attrs) do
    product
    |> Repo.preload(:categories)
    |> Repo.preload(:tags)
    |> Repo.preload(:option_values)
    |> cast(attrs, @fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:company)
    |> assoc_constraint(:user)
    |> put_assoc(:categories, Store.load_categories(attrs))
    |> put_assoc(:tags, Store.load_tags(attrs))
    |> cast_assoc(:option_values)
    |> no_assoc_constraint(:items, message: "This product is still associated with sales")
    |> add_product_slug(attrs)
    |> unique_constraint(:slug)
  end

  @doc false
  def delete_changeset(product) do
    product
    |> Repo.preload(:categories)
    |> Repo.preload(:tags)
    |> Repo.preload(:items)
    |> cast(%{}, [])
    |> no_assoc_constraint(:items, message: "This product is still associated with sales")
  end

  # get product name
  def get_product_name(product) do
    product = Repo.preload(product, [:product_group, :option_values])

    case product.option_values do
      [] ->
        product.product_group.title

      _ ->
        "#{product.product_group.title} (#{
          Enum.map(product.option_values, &(&1.name || "?")) |> Enum.join(" ")
        })"
    end
  end

  # get product name
  def product_name_based_on_visual_options(product) do
    product = Repo.preload(product, [:product_group, option_values: [:option]])

    case product.option_values do
      [] ->
        product.product_group.title

      _ ->
        "#{product.product_group.title} (#{
          visual_option_values_names(product.option_values) |> Enum.join(" ")
        })"
    end
  end

  def get_product_share_link(product) do
    product = Repo.preload(product, [:company])
    "#{Business.get_company_share_domain()}/#{product.company.slug}/p/#{product.slug}"
  end

  defp add_product_slug(changeset, attrs) do
    title = Map.get(attrs, :title) |> String.split(" ") |> Enum.join("-")

    hash_from_product_grp_uuid = Map.get(attrs, :product_group_id) |> hash_from_product_grp_uuid

    option_values = Map.get(attrs, :option_values)

    slug =
      case option_values do
        [] ->
          "#{title}-#{hash_from_product_grp_uuid}"

        _ ->
          "#{title}-#{
            Enum.map(option_values, &(remove_space(&1.name) || ""))
            |> Enum.join("-")
          }-#{hash_from_product_grp_uuid}"
      end
      |> String.downcase()
      |> URI.encode()

    put_change(changeset, :slug, slug)
  end

  defp hash_from_product_grp_uuid(id) do
    id
    |> String.split("-")
    |> List.last()
  end

  defp remove_space(string) do
    String.split(string, " ") |> Enum.join("-")
  end

  defp visual_option_values_names(option_values) do
    Enum.map(option_values, fn option_value ->
      if option_value.option.is_visual == "yes" do
        option_value.name
      else
        ""
      end
    end)
  end
end
