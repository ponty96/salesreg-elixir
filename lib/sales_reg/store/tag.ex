defmodule SalesReg.Store.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Store.{Product, Service}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tags" do
    field(:name, :string)

    belongs_to(:company, SalesReg.Business.Company)
    many_to_many(:products, Product, join_through: "products_tags", on_delete: :delete_all)
    many_to_many(:services, Service, join_through: "services_tags", on_delete: :delete_all)

    timestamps()
  end

  @required_fields [:name]
  @doc false
  def changeset(service, attrs) do
    service
    |> Repo.preload(:categories)
    |> cast(attrs, @required_fields ++ [:description])
    |> validate_required(@required_fields)
    |> assoc_constraint(:company)
    |> assoc_constraint(:user)
    |> put_assoc(:categories, Store.load_categories(attrs))
  end
end
