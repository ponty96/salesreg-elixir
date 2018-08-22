defmodule SalesReg.Business.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  alias SalesReg.Business.Company
  alias SalesReg.Repo

  schema "contacts" do
    field(:image, :string)
    field(:contact_name, :string)
    field(:email, :string)
    field(:currency, :string)
    field(:birthday, :string)
    field(:marital_status, :string)
    field(:marriage_anniversary, :string)
    field(:likes, {:array, :string})
    field(:dislikes, {:array, :string})
    field(:type, :string)

    belongs_to(:company, Company)
    belongs_to(:user, SalesReg.Accounts.User)

    has_one(:address, SalesReg.Business.Location, on_replace: :delete)
    has_one(:phone, SalesReg.Business.Phone, on_replace: :delete)
    has_one(:bank, SalesReg.Business.Bank, on_replace: :delete)

    timestamps()
  end

  @required_fields [
    :contact_name,
    :email,
    :company_id,
    :user_id,
    :currency,
    :type
  ]
  @optional_fields [
    :image,
    :birthday,
    :marital_status,
    :marriage_anniversary,
    :likes,
    :dislikes
  ]

  @doc false
  def changeset(contact, attrs) do
    contact
    |> Repo.preload([:address, :phone, :bank])
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,63}$/)
    |> validate_contact_type()
    |> assoc_constraint(:company)
    |> assoc_constraint(:user)
    |> cast_assoc(:address)
    |> cast_assoc(:phone)
    |> cast_assoc(:bank)
  end

  defp validate_contact_type(changeset) do
    case get_field(changeset, :type) do
      "customer" -> changeset
      "vendor" -> changeset
      _ -> add_error(changeset, :type, "Invalid contact type")
    end
  end
end
