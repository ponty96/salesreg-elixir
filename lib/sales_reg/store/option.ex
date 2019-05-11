defmodule SalesReg.Store.Option do
  @moduledoc """
  Option Schema Module
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias SalesReg.Repo
  alias SalesReg.Store

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "options" do
    field(:name, :string)
    field(:is_visual, :string, default: "no")
    belongs_to(:company, SalesReg.Business.Company)

    many_to_many(:product_groups, Store.ProductGroup,
      join_through: "product_groups_options",
      on_replace: :delete
    )

    has_many(:option_values, Store.OptionValue)

    timestamps()
  end

  @doc false
  def changeset(option, attrs) do
    option
    |> Repo.preload(:product_groups)
    |> cast(attrs, [:name, :company_id, :is_visual])
    |> validate_required([:name, :company_id])
  end

  @doc false
  def delete_changeset(option) do
    option
    |> cast(%{}, [])
    |> no_assoc_constraint(:option_values,
      message: "This option is being used in at least one products"
    )
  end
end
