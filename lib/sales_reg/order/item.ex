defmodule SalesReg.Order.Item do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "items" do
    field(:quantity, :string)
    field(:unit_price, :string)

    belongs_to(:sale, SalesReg.Order.Sale)
    belongs_to(:product, SalesReg.Store.Product)

    timestamps()
  end

  @required_fields [:quantity, :unit_price, :product_id]

  @doc false
  def changeset(item, attrs) do
    IO.inspect(attrs, label: "items attrs")

    item
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:product)
  end
end
