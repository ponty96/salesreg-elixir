defmodule SalesReg.Business.Phone do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "phones" do
    field(:type, :string, default: "Mobile")
    field(:number, :string)
    belongs_to(:contact, SalesReg.Business.Contact)
    belongs_to(:company, SalesReg.Business.Company)

    timestamps()
  end

  @doc false
  def changeset(phone, attrs) do
    phone
    |> cast(attrs, [:type, :number])
    |> validate_required([:type, :number])
    |> unique_constraint(:number)
    |> assoc_constraint(:contact)
    |> assoc_constraint(:company)
  end
end
