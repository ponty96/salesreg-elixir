defmodule SalesReg.Order.DeliveryFee do
  @moduledoc """
  Delivery Fee Schema Module
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Base

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "delivery_fees" do
    field(:fee, :decimal)
    field(:state, :string)
    field(:region, :string)

    belongs_to(:company, SalesReg.Business.Company)
    belongs_to(:user, SalesReg.Accounts.User)

    timestamps()
  end

  @required_fields [
    :fee,
    :state,
    :region,
    :user_id,
    :company_id
  ]
  @optional_fields []
  @number_fields [:fee]

  def changeset(delivery_fee, attrs) do
    new_attrs = Base.transform_string_keys_to_numbers(attrs, [:fee])

    delivery_fee
    |> cast(new_attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:user)
    |> assoc_constraint(:company)
    |> unique_constraint(:region,
      name: :state_region_index,
      message: "This region has already been taken for this state."
    )
    |> Base.validate_changeset_number_values(@number_fields)
  end

  def delete_changeset(delivery_fee) do
    delivery_fee
    |> cast(%{}, [])
  end
end
