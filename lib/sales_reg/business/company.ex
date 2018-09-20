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
    field(:category, :string)
    field(:description, :string)
    field(:logo, :string)

    belongs_to(:owner, SalesReg.Accounts.User)
    has_many(:branches, Branch)
    has_many(:contacts, Contact)
    has_many(:purchases, SalesReg.Order.Purchase)
    has_one(:phone, SalesReg.Business.Phone, on_replace: :delete)
    timestamps()
  end

  @required_fields [:title, :contact_email, :owner_id, :category]
  @optional_fields [:about, :currency, :description, :logo]
  @doc false
  def changeset(company, attrs) do
    company
    |> Repo.preload([:phone])
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_assoc(:phone)
    |> validate_required(@required_fields)
    # |> cast_assoc(:branches)
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
