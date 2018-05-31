defmodule SalesReg.Business.Employee do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "employees" do
    belongs_to(:employer, SalesReg.Business.Company)
    belongs_to(:person, SalesReg.Accounts.User)
    belongs_to(:branch, SalesReg.Business.Branch)

    timestamps()
  end

  @required_fields [:person_id, :employer_id, :branch_id]
  @doc false
  def changeset(employee, attrs) do
    employee
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:employer)
    |> assoc_constraint(:person)
    |> assoc_constraint(:branch)
  end
end
