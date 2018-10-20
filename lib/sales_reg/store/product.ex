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
    field(:images, {:array, :string})
    field(:name, :string)
    field(:stock_quantity, :string)
    field(:minimum_stock_quantity, :string)
    field(:cost_price, :string)
    field(:selling_price, :string)

    belongs_to(:company, SalesReg.Business.Company)
    belongs_to(:user, SalesReg.Accounts.User)

    many_to_many(:categories, Category,
      join_through: "products_categories",
      on_replace: :delete,
      on_delete: :delete_all
    )

    timestamps()
  end

  @fields [
    :images,
    :description
  ]

  @required_fields [
    :name,
    :selling_price,
    :company_id,
    :user_id,
    :stock_quantity,
    :minimum_stock_quantity,
    :cost_price
  ]
  @doc false
  def changeset(product, attrs) do
    product
    |> Repo.preload(:categories)
    |> cast(attrs, @fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:company)
    |> assoc_constraint(:user)
    |> put_assoc(:categories, Store.load_categories(attrs))
  end
end
