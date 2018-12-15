defmodule SalesReg.Store.Option do
  use Ecto.Schema
  import Ecto.Changeset

  alias SalesReg.Store
  alias SalesReg.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "options" do
    field(:name, :string)
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
    |> cast(attrs, [:name, :company_id])
    |> validate_required([:name, :company_id])
  end

  @doc false
  def delete_changeset(option) do
    option
    |> cast(%{}, [])
    |> no_assoc_constraint(:option_values,
      message: "This option is being used in several products or services"
    )
  end
end
