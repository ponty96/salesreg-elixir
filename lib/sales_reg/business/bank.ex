defmodule SalesReg.Business.Bank do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "banks" do
    field(:account_name, :string)
    field(:account_number, :string)
    field(:bank_name, :string)

    belongs_to(:contact, SalesReg.Business.Contact)

    timestamps()
  end

  @required_fields [:account_name, :account_number, :bank_name]
  @optional_fields []

  @doc false
  def changeset(bank, attrs) do
    bank
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:contact)
  end
end
