defmodule SalesReg.Business.Vendor do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "vendors" do
    field(:email, :string)
    field(:fax, :string)
    field(:city, :string)
    field(:state, :string)
    field(:country, :string)
    field(:currency, :string)
    
    belongs_to(:user, SalesReg.Accounts.User)
    belongs_to(:company, SalesReg.Business.Company)
    has_many(:locations, SalesReg.Business.Location)
    timestamps()
  end

  @required_fields [:email, :fax, :currency, :city, :state, :country, :user_id, :company_id]
  @optional_fields []
  
  @doc false
  def changeset(company, attrs) do
    company
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,63}$/)
    |> unique_constraint(:email)
    |> assoc_constraint(:company)
    |> assoc_constraint(:user)
  end
end
