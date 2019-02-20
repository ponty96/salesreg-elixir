defmodule SalesReg.Order.DeliveryFee do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "delivery_fees" do
    field(:price, :string)
    field(:location, :string)

    belongs_to(:company, SalesReg.Business.Company)
    belongs_to(:user, SalesReg.Accounts.User)

    timestamps()
  end

  @required_fields [
    :price,
    :location,
    :user_id,
    :company_id
  ]
  @optional_fields []

  def changeset(delivery_fee, attrs) do
    delivery_fee
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:user)
    |> assoc_constraint(:company)
    |> unique_constraint(:location)
  end

  def delete_changeset(delivery_fee) do
    delivery_fee
    |> cast(%{}, [])
  end
end
