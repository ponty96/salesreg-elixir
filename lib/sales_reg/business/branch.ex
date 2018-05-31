defmodule SalesReg.Business.Branch do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "branches" do
    field(:type, :string, default_value: "Other Branch")

    belongs_to(:company, SalesReg.Business.Company)
    has_many(:employees, SalesReg.Business.Employee)
    has_one(:location, SalesReg.Business.Location)

    timestamps()
  end

  @doc false
  def changeset(branch, attrs) do
    branch
    |> cast(attrs, [:type, :company_id])
    |> validate_required([:type, :company_id])
    |> cast_assoc(:location)
  end
end
