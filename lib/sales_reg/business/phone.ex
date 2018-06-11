defmodule SalesReg.Business.Phone do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "phones" do
    field(:type, :string)
    field(:number, :string)
    belongs_to(:contact, SalesReg.Business.Contact)

    timestamps()
  end

  @doc false
  def changeset(phone, attrs) do
    phone
    |> cast(attrs, [:type, :number])
    |> validate_required([:type, :number])
    |> assoc_constraint(:contact)
    |> unique_constraint(:number)
  end
end
