defmodule SalesReg.Store.Product do
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Store.Category
  alias SalesReg.Repo
  alias SalesReg.Store

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

    belongs_to(:company, SalesReg.Business.Company)
    belongs_to(:user, SalesReg.Accounts.User)

    has_many(:items, SalesReg.Order.Item)
    has_many(:review, SalesReg.Order.Review)
    has_many(:star, SalesReg.Order.Star)

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
    :name
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
end
