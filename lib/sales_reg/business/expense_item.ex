defmodule SalesReg.Business.ExpenseItem do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "expense_items" do
    field(:item_name, :string)
    field(:amount, :string)

    belongs_to(:expense, SalesReg.Business.Expense, foreign_key: :expense_id)

    timestamps()
  end

  @required_fields [:item_name, :amount]
  @optional_fields [:expense_id]

  @doc false
  def changeset(expense_item, attrs) do
    expense_item
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
