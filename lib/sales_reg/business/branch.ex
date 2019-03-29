defmodule SalesReg.Business.Branch do
  @moduledoc """
  Branch Schema Module
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "branches" do
    field(:type, :string, default_value: "Other Branch")

    belongs_to(:company, SalesReg.Business.Company)
    has_one(:location, SalesReg.Business.Location, on_replace: :delete)

    timestamps()
  end

  @doc false
  def changeset(branch, attrs) do
    branch
    |> Repo.preload([:location])
    |> cast(attrs, [:type, :company_id])
    |> validate_required([:type, :company_id])
    |> cast_assoc(:location)
  end
end
