defmodule SalesReg.Store.Product do
  @moduledoc """
  Product Schema Module
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Base
  alias SalesReg.Business
  alias SalesReg.Repo
  alias SalesReg.Store
  alias SalesReg.Store.Category

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "products" do
    field(:description, :string)
    field(:name, :string)
    field(:sku, :integer)
    field(:minimum_sku, :integer)
    field(:cost_price, :decimal)
    field(:price, :decimal)
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
    :featured_image
  ]

  @number_fields [:sku, :minimum_sku, :cost_price, :price]

  @doc false
  def changeset(product, attrs) do
    new_attrs =
      attrs
      |> Base.transform_string_keys_to_numbers([:price, :cost_price])
      |> Base.convert_string_keys_integer([:sku, :minimum_sku])

    product
    |> Repo.preload(:categories)
    |> Repo.preload(:tags)
    |> cast(new_attrs, @fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:company)
    |> assoc_constraint(:user)
    |> put_assoc(:categories, Store.load_categories(attrs))
    |> put_assoc(:tags, Store.load_tags(attrs))
    |> no_assoc_constraint(:items, message: "This product is still associated with sales")
    |> add_product_slug(attrs)
    |> unique_constraint(:slug)
    |> Base.validate_changeset_number_values(@number_fields)
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

  def get_product_share_link(product) do
    product = Repo.preload(product, [:company])
    "#{Business.get_company_share_url(product.company.slug)}/store/products/#{product.slug}"
  end

  defp add_product_slug(changeset, attrs) do
    title = attrs |> Map.get(:title) |> String.split(" ") |> Enum.join("-")

    slug =
      title
      |> String.downcase()
      |> URI.encode()

    put_change(changeset, :slug, slug)
  end

  defp remove_space(string) do
    string |> String.split(" ") |> Enum.join("-")
  end
end
