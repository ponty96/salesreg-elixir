defmodule SalesReg.Business.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  alias SalesReg.Business.Company
  alias SalesReg.Repo

  schema "customers" do
    field(:image, :string)
    field(:customer_name, :string)
    field(:email, :string)
    field(:currency, :string)
    field(:birthday, :string)
    field(:marital_status, :string)
    field(:marriage_anniversary, :string)
    field(:likes, {:array, :string})
    field(:dislikes, {:array, :string})

    belongs_to(:company, Company)
    belongs_to(:user, SalesReg.Accounts.User)

    has_one(:address, SalesReg.Business.Location, on_replace: :delete)
    has_one(:phone, SalesReg.Business.Phone, on_replace: :delete)
    has_one(:bank, SalesReg.Business.Bank, on_replace: :delete)

    timestamps()
  end

  @required_fields [
    :customer_name,
    :email,
    :company_id,
    :user_id,
    :currency,
    :birthday,
    :marital_status,
    :marriage_anniversary,
    :likes,
    :dislikes
  ]
  @optional_fields [:image]

  @doc false
  def changeset(customer, attrs) do
    customer
    |> Repo.preload([:address, :phone, :bank])
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_assoc(:address)
    |> cast_assoc(:phone)
    |> cast_assoc(:bank)
    |> validate_required(@required_fields)
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,63}$/)
    |> assoc_constraint(:company)
    |> assoc_constraint(:user)
  end
end
