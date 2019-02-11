defmodule SalesReg.Business.Bank do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "banks" do
    field(:account_name, :string)
    field(:account_number, :string)
    field(:bank_name, :string)
    field(:bank_code, :string)
    field(:subaccount_id, :string)

    belongs_to(:company, SalesReg.Business.Company)

    timestamps()
  end

  @required_fields [
    :account_number, 
    :bank_name, 
    :company_id, 
    :account_name, 
    :bank_code
  ]
  
  @optional_fields [:subaccount_id]

  @doc false
  def changeset(bank, attrs) do
    bank
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:company)
  end

  def delete_changeset(bank) do
    bank
    |> cast(%{}, [])
  end
end
