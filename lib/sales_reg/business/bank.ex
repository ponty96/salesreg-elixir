defmodule SalesReg.Business.Bank do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  alias SalesReg.Business.Customer
  alias SalesReg.Repo

  schema "banks" do
    field(:account_name, :string)
    field(:account_number, :string)
    field(:account_bank, :string)

    belongs_to(:customer, SalesReg.Business.Customer)

    timestamps()
  end

  @required_fields [:account_name, :account_number, :account_bank]
  @optional_fields []

  @doc false
  def changeset(bank, attrs) do
    bank
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:customer)
  end
end
