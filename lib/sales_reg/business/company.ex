defmodule SalesReg.Business.Company do
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  alias SalesReg.Business.{Branch, Contact}

  schema "companies" do
    field(:about, :string)
    field(:contact_email, SalesReg.FieldTypes.CaseInsensitive)
    field(:currency, :string)
    field(:title, :string)
    field(:description, :string)
    field(:logo, :string)
    field(:cover_photo, :string)
    field(:slug, SalesReg.FieldTypes.CaseInsensitive)
    field(:facebook, :string)
    field(:twitter, :string)
    field(:instagram, :string)
    field(:linkedin, :string)

    belongs_to(:owner, SalesReg.Accounts.User)
    has_many(:branches, Branch)
    has_many(:contacts, Contact)
    has_many(:invoices, SalesReg.Order.Invoice)
    has_one(:phone, SalesReg.Business.Phone, on_replace: :delete)
    has_one(:bank, SalesReg.Business.Bank, on_replace: :delete)
    has_one(:company_template, SalesReg.Theme.CompanyTemplate)
    has_many(:sales, SalesReg.Order.Sale)
    has_many(:reviews, SalesReg.Order.Review)
    has_many(:stars, SalesReg.Order.Star)
    has_many(:legal_documents, SalesReg.Business.LegalDocument)

    timestamps()
  end

  @required_fields [:title, :contact_email, :owner_id, :currency, :slug]
  @optional_fields [:about, :description, :logo, :facebook, :twitter, :instagram, :linkedin]

  @doc false
  def changeset(company, attrs) do
    company
    |> Repo.preload([:phone, :bank, :legal_documents])
    |> change(attrs)
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> unique_constraint(:owner_id, message: "Sorry, but you already have a business with us")
    |> foreign_key_constraint(:owner_id)
    |> cast_assoc(:phone)
    |> cast_assoc(:legal_documents)
    |> validate_required(@required_fields)
    |> validate_format(:slug, ~r/^[a-zA-Z\d][a-zA-Z\d-_]+[a-zA-Z\d]$/)
  end
end
