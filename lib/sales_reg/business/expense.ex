defmodule SalesReg.Business.Expense do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  alias SalesReg.Business.Company
  alias SalesReg.Repo

  schema "expenses" do
    field(:title, :string)
    field(:date, :string)
    field(:total_amount, :string)
    field(:payment_method, :string)
    
    belongs_to(:paid_by, SalesReg.Accounts.User, foreign_key: :paid_by_id)
    belongs_to(:paid_to, SalesReg.Accounts.User, foreign_key: :paid_to_id)
    belongs_to(:company, Company)
    has_many(:expense_items, SalesReg.Business.ExpenseItems, on_replace: :delete)

    timestamps()
  end

  @required_fields [
    :title,
    :date,
    :total_amount,
    :payment_method,
    :paid_by_id,
    :paid_to_id,
    :company_id
  ]
  @optional_fields []

  @doc false
  def changeset(expense, attrs) do
    expense
    |> Repo.preload([:expense_items])
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_assoc(:expense_items)
    |> validate_required(@required_fields)
    |> assoc_constraint(:company)
    |> assoc_constraint(:paid_by)
    |> assoc_constraint(:paid_to)
  end
end
