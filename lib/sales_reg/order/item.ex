defmodule SalesReg.Order.Item do
  @moduledoc """
  Item Schema Module
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Base

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "items" do
    field(:quantity, :decimal)
    field(:unit_price, :decimal)

    belongs_to(:sale, SalesReg.Order.Sale)
    belongs_to(:product, SalesReg.Store.Product)

    timestamps()
  end

  @required_fields [:quantity, :unit_price, :product_id]

  @doc false
  def changeset(item, attrs) do
    new_attrs = Base.transform_string_keys_to_numbers(attrs, [:quantity, :unit_price])

    item
    |> cast(new_attrs, @required_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:product)
  end
end
