defmodule SalesReg.Store.OptionValue do
  use Ecto.Schema
  import Ecto.Changeset

  alias SalesReg.Store

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "option_values" do
    field(:name, :string)
    belongs_to(:company, SalesReg.Business.Company)
    belongs_to(:option, Store.Option)

    belongs_to(:product, Store.Product)

    timestamps()
  end

  @fields [:name, :company_id, :option_id]

  @doc false
  def changeset(option_values, attrs) do
    option_values
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> assoc_constraint(:option)
    |> assoc_constraint(:product)
  end
end
