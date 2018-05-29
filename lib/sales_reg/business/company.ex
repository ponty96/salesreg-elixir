defmodule SalesReg.Business.Company do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  alias SalesReg.Business.{
    Branch,
    Employee
  }

  schema "companies" do
    field(:about, :string)
    field(:contact_email, :string)
    field(:title, :string)

    belongs_to(:owner, SalesReg.Accounts.User)
    has_many(:branches, Branch)

    has_many(:employees, Employee)
    timestamps()
  end

  @required_fields [:title, :contact_email, :owner_id]
  @doc false
  def changeset(company, attrs) do
    company
    |> cast(attrs, @required_fields ++ [:about])
    |> validate_required(@required_fields)
    |> cast_assoc(:branches)
  end
end
