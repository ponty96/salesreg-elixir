defmodule SalesReg.Order.DeliveryDate do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "delivery_dates" do
    field(:date, :string)
    field(:confirmed, :boolean)

    belongs_to(:sale, SalesReg.Order.Sale)
    belongs_to(:company, SalesReg.Business.Company)
    belongs_to(:user, SalesReg.Accounts.User)

    timestamps()
  end

  @required_fields [
    :date,
    :confirmed,
    :sale_id,
    :user_id,
    :company_id
  ]
  @optional_fields []

  def changeset(delivery_date, attrs) do
    delivery_date
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:sale)
    |> assoc_constraint(:user)
    |> assoc_constraint(:company)
  end
end
