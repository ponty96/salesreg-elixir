defmodule SalesReg.Business.Company do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  alias SalesReg.Business.{
    Branch,
    Employee,
    Contact,
    Vendor
  }

  schema "companies" do
    field(:about, :string)
    field(:contact_email, :string)
    field(:title, :string)
    field(:category, :string)

    belongs_to(:owner, SalesReg.Accounts.User)
    has_many(:branches, Branch)
    has_many(:contacts, Contact)
    has_many(:vendors, Vendor)

    many_to_many(:users, SalesReg.Accounts.User, join_through: Employee)
    timestamps()
  end

  @required_fields [:title, :contact_email, :owner_id, :category]
  @doc false
  def changeset(company, attrs) do
    company
    |> cast(attrs, @required_fields ++ [:about])
    |> validate_required(@required_fields)
    |> cast_assoc(:branches)
    |> validate_category()
  end

  def validate_category(changeset) do
    case get_field(changeset, :category) do
      "product" -> changeset
      "service" -> changeset
      "product_service" -> changeset
      _ -> add_error(changeset, :category, "Invalid category")
    end
  end
end
