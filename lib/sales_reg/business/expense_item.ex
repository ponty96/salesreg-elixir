defmodule SalesReg.Business.ExpenseItem do
  @moduledoc """
  Expense Item Schema Module
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Base

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "expense_items" do
    field(:item_name, :string)
    field(:amount, :decimal)

    belongs_to(:expense, SalesReg.Business.Expense, foreign_key: :expense_id)

    timestamps()
  end

  @required_fields [:item_name, :amount]
  @optional_fields [:expense_id]
  @number_fields [:amount]

  @doc false
  def changeset(expense_item, attrs) do
    expense_item
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> Base.validate_changeset_number_values(@number_fields)
  end
end
