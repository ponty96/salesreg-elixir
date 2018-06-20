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
    field(:fax, :string)
    field(:city, :string)
    field(:state, :string)
    field(:country, :string)

    belongs_to(:company, Company)
    belongs_to(:user, SalesReg.Accounts.User)

    has_one(
      :residential_add,
      SalesReg.Business.Location,
      foreign_key: :residential_add_id,
      on_replace: :delete
    )

    has_one(
      :office_add,
      SalesReg.Business.Location,
      foreign_key: :office_add_id,
      on_replace: :delete
    )

    has_many(:phones, SalesReg.Business.Phone, on_replace: :delete)

    timestamps()
  end

  @required_fields [
    :customer_name,
    :email,
    :fax,
    :city,
    :state,
    :country,
    :company_id,
    :user_id
  ]
  @optional_fields [:image]

  @doc false
  def changeset(customer, attrs) do
    customer
    |> Repo.preload([:residential_add, :office_add, :phones])
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_assoc(:residential_add)
    |> cast_assoc(:office_add)
    |> cast_assoc(:phones)
    |> validate_required(@required_fields)
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,63}$/)
    |> assoc_constraint(:company)
    |> assoc_constraint(:user)
  end
end
