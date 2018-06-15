defmodule SalesReg.Order.Item do
  use Ecto.Schema
  import Ecto.Changeset


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "items" do
    field :name, :string
    field :quantity, :string
    field :unit_price, :string
    
    belongs_to :purchase, SalesReg.Order.Purchase

    timestamps()
  end

  @required_fields [:name, :quantity, :unit_price]
  @optional_fields []

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:purchase)
  end
end
