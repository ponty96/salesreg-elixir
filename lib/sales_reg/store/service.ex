defmodule SalesReg.Store.Service do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "services" do
    field(:description, :string)
    field(:name, :string)
    field(:price, :string)
    field(:images, {:array, :string})

    belongs_to(:company, SalesReg.Business.Company)
    belongs_to(:user, SalesReg.Accounts.User)

    timestamps()
  end

  @required_fields [:name, :price, :company_id, :user_id]
  @optional_fields [:description, :images]

  @doc false
  def changeset(service, attrs) do
    service
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:company)
    |> assoc_constraint(:user)
  end
end
