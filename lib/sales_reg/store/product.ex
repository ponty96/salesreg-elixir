defmodule SalesReg.Store.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "products" do
    field(:description, :string)
    field(:featured_image, :string)
    field(:name, :string)
    field(:pack_quantity, :string)
    field(:price_per_pack, :string)
    field(:selling_price, :string)
    field(:unit_quantity, :string)

    belongs_to(:company, SalesReg.Business.Company)
    belongs_to(:user, SalesReg.Accounts.User)

    timestamps()
  end

  @fields [
    :featured_image,
    :pack_quantity,
    :price_per_pack,
    :unit_quantity,
    :description,
    :company_id,
    :user_id
  ]

  @required_fields [:name, :selling_price, :company_id, :user_id]
  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, @fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:company)
    |> assoc_constraint(:user)
  end
end
