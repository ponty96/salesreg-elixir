defmodule SalesReg.Business.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  alias SalesReg.Business.Company

  schema "contacts" do
    field(:image, :string)
    field(:customer_name, :string)
    field(:phone1, :string)
    field(:phone2, :string)
    field(:residential_add, :string)
    field(:office_add, :string)
    field(:email, :string)
    field(:fax, :string)
    field(:city, :string)
    field(:state, :string)
    field(:country, :string)

    belongs_to(:company, Company)
    belongs_to(:user, SalesReg.Accounts.User)

    timestamps()
  end

  @required_fields [
    :customer_name,
    :office_add,
    :email,
    :residential_add,
    :fax,
    :company_id,
    :user_id
  ]
  @optional_fields [:image, :phone1, :phone2, :city, :state, :country]

  @doc false
  def changeset(company, attrs) do
    company
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,63}$/)
    |> assoc_constraint(:company)
    |> assoc_constraint(:user)
  end
end
