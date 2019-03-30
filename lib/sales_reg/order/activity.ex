defmodule SalesReg.Order.Activity do
  @moduledoc """
  Activity Schema Module
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Base

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @types ["due_payment", "closed_order", "payment"]

  schema "activities" do
    field(:type, :string)
    field(:amount, :decimal)

    belongs_to(:invoice, SalesReg.Order.Invoice)
    belongs_to(:contact, SalesReg.Business.Contact)
    belongs_to(:company, SalesReg.Business.Company)

    timestamps()
  end

  @required_fields [
    :type,
    :amount,
    :invoice_id,
    :contact_id,
    :company_id
  ]
  @optional_fields []

  def changeset(activity, attrs) do
    new_attrs = Base.transform_string_keys_to_numbers(attrs, [:amount])

    activity
    |> cast(new_attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:invoice)
    |> assoc_constraint(:contact)
    |> assoc_constraint(:company)
    |> validate_inclusion(:type, @types)
  end
end
