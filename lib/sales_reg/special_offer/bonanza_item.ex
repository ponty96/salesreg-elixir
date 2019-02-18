defmodule SalesReg.SpecialOffer.BonanzaItem do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "bonanza_items" do
    field(:price_slash_to, :string)
    field(:max_quantity, :string)

    belongs_to(:product, SalesReg.Store.Product)
    belongs_to(:bonanza, SalesReg.SpecialOffer.Bonanza)

    timestamps()
  end

  @required_fields [
    :price_slash_to,
    :max_quantity,
    :product_id
  ]

  @optional_fields []

  @doc false
  def changeset(bonanza, attrs) do
    bonanza
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:product)
  end

  def delete_changeset(bonanza_item) do
    bonanza_item
    |> cast(%{}, [])
  end
end
