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
    field(:stock_quantity, :string)
    field(:minimum_stock_quantity, :string)
    field(:cost_price, :string)
    field(:selling_price, :string)
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
      on_replace: :delete,
      on_delete: :delete_all
    )

    many_to_many(:tags, SalesReg.Store.Tag, join_through: "products_tags", on_delete: :delete_all)

    timestamps()
  end

  @fields [
    :description,
    :images,
    :is_featured,
    :is_top_rated_by_merchant
  ]

  @required_fields [
    :name,
    :selling_price,
    :company_id,
    :user_id,
    :stock_quantity,
    :minimum_stock_quantity,
    :cost_price,
    :featured_image
  ]
  @doc false
  def changeset(product, attrs) do
    product
    |> Repo.preload(:categories)
    |> Repo.preload(:tags)
    |> cast(attrs, @fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:company)
    |> assoc_constraint(:user)
    |> put_assoc(:categories, Store.load_categories(attrs))
    |> put_assoc(:tags, Store.load_tags(attrs))
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
