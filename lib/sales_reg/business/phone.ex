defmodule SalesReg.Business.Phone do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "phones" do
    field(:type, :string, default: "Mobile")
    field(:number, :string)
    belongs_to(:customer, SalesReg.Business.Customer)
    belongs_to(:user, SalesReg.Accounts.User)

    timestamps()
  end

  @doc false
  def changeset(phone, attrs) do
    phone
    |> cast(attrs, [:type, :number])
    |> validate_required([:type, :number])
    |> assoc_constraint(:customer)
    |> assoc_constraint(:user)
  end
end
