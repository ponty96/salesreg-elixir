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
    field(:type, :string)

    belongs_to(:branch, SalesReg.Business.Branch)
    belongs_to(:contact, SalesReg.Business.Contact, foreign_key: :contact_id)
    belongs_to(:user, SalesReg.Accounts.User)
    belongs_to(:sale, SalesReg.Order.Sale)

    timestamps()
  end

  @required_fields [:street1, :city, :state, :country]
  @fields [:street2, :lat, :long, :type, :sale_id]

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, @required_fields ++ @fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:branch)
    |> assoc_constraint(:contact)
    |> assoc_constraint(:user)
  end
end
