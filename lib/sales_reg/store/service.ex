defmodule SalesReg.Store.Service do
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Store.Category

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "services" do
    field(:description, :string)
    field(:name, :string)
    field(:price, :string)

    belongs_to(:company, SalesReg.Business.Company)
    belongs_to(:user, SalesReg.Accounts.User)

    many_to_many(:categories, Category,
      join_through: "services_categories",
      on_replace: :delete,
      on_delete: :delete_all
    )

    timestamps()
  end

  @required_fields [:name, :price, :company_id, :user_id]
  @doc false
  def changeset(service, attrs) do
    service
    |> cast(attrs, @required_fields ++ [:description])
    |> validate_required(@required_fields)
    |> assoc_constraint(:company)
    |> assoc_constraint(:user)
  end
end
