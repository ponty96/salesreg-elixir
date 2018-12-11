defmodule SalesReg.Business.Company do
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  alias SalesReg.Business.{Branch, Contact}

  schema "companies" do
    field(:about, :string)
    field(:contact_email, :string)
    field(:currency, :string)
    field(:title, :string)
    field(:description, :string)
    field(:logo, :string)
    field(:cover_photo, :string)

    belongs_to(:owner, SalesReg.Accounts.User)
    has_many(:branches, Branch)
    has_many(:contacts, Contact)
    has_many(:purchases, SalesReg.Order.Purchase)
    has_many(:invoices, SalesReg.Order.Invoice)
    has_one(:phone, SalesReg.Business.Phone, on_replace: :delete)
    has_one(:bank, SalesReg.Business.Bank, on_replace: :delete)
    has_one(:company_template, SalesReg.Theme.CompanyTemplate)
    timestamps()
  end

  @required_fields [:title, :contact_email, :owner_id, :currency]
  @optional_fields [:about, :description, :logo]

  @doc false
  def changeset(company, attrs) do
    company
    |> Repo.preload([:phone, :bank])
    |> change(attrs)
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> unique_constraint(:owner_id, message: "Sorry, but you already have a business with us")
    |> cast_assoc(:phone)
    |> validate_required(@required_fields)

    # |> cast_assoc(:branches)
  end
end
