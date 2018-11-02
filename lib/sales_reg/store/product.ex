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
    field(:featured_image, :string)
    field(:name, :string)
    field(:sku, :string)
    field(:minimum_sku, :string)
    field(:cost_price, :string)
    field(:selling_price, :string)

    belongs_to(:company, SalesReg.Business.Company)
    belongs_to(:user, SalesReg.Accounts.User)

    many_to_many(:categories, Category,
      join_through: "products_categories",
      on_replace: :delete
    )

    many_to_many(:tags, Store.Tag, join_through: "products_tags")

    has_many(:option_values, Store.OptionValue, on_replace: :delete)

    belongs_to(:product_group, Store.ProductGroup)

    timestamps()
  end

  @fields [
    :featured_image,
    :description,
    :product_group_id,
    :cost_price
  ]

  @required_fields [
    :name,
    :selling_price,
    :company_id,
    :user_id,
    :sku,
    :minimum_sku
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
  end
end
