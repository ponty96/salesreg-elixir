defmodule SalesReg.Store.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Store.{Product, Service}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tags" do
    field(:name, :string)

    belongs_to(:company, SalesReg.Business.Company)
    many_to_many(:products, Product, join_through: "products_tags")
    many_to_many(:services, Service, join_through: "services_tags")

    timestamps()
  end

  @required_fields [:name, :company_id]
  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:company)
  end
end
