defmodule SalesReg.Business.Location do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "locations" do
    field(:city, :string)
    field(:country, :string)
    field(:lat, :string)
    field(:long, :string)
    field(:state, :string)
    field(:street1, :string)
    field(:street2, :string)
    belongs_to(:branch, SalesReg.Business.Branch)
    belongs_to(:vendor, SalesReg.Business.Vendor)

    timestamps()
  end

  @required_fields [:street1, :city, :state, :country, :vendor_id]
  @fields [:street2, :lat, :long]
  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, @required_fields ++ @fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:branch)
  end
end
