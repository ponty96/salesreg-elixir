defmodule SalesReg.SpecialOffer.BonanzaItem do
  @moduledoc """
  Bonanza Item Schema Module
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Base

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "bonanza_items" do
    field(:price_slash_to, :decimal)
    field(:max_quantity, :decimal)

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
    new_attrs = Base.transform_string_keys_to_numbers(attrs, [:price_slash_to, :max_quantity])

    bonanza
    |> cast(new_attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:product)
  end

  def delete_changeset(bonanza_item) do
    bonanza_item
    |> cast(%{}, [])
  end
end
