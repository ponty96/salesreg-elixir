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
    field(:total_amount, :decimal)
    field(:items_amount, :decimal, virtual: true)
    field(:payment_method, :string)

    belongs_to(:paid_by, SalesReg.Accounts.User, foreign_key: :paid_by_id)
    belongs_to(:company, Company)

    has_many(:expense_items, SalesReg.Business.ExpenseItem,
      on_replace: :delete,
      on_delete: :delete_all
    )

    timestamps()
  end

  @required_fields [
    :title,
    :date,
    :total_amount,
    :payment_method,
    :paid_by_id,
    :company_id
  ]
  @optional_fields [:items_amount]

  @doc false
  def changeset(expense, attrs) do
    expense
    |> Repo.preload([:expense_items])
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_assoc(:expense_items)
    |> validate_required(@required_fields)
    |> assoc_constraint(:company)
    |> assoc_constraint(:paid_by)
    |> validate_total_amount(expense)
  end

  def delete_changeset(expense) do
    expense
    |> Repo.preload([:expense_items])
    |> cast(%{}, [])
  end

  defp validate_total_amount(
         %Ecto.Changeset{changes: %{expense_items: _items}} = changeset,
         expense
       ) do
    total_amount =
      total_amount(expense, changeset)
      |> Decimal.to_float()
      |> Float.round(2)

    items_amount =
      changeset.changes.items_amount
      |> Decimal.to_float()
      |> Float.round(2)

    cond do
      items_amount < total_amount ->
        add_error(
          changeset,
          :total_amount,
          "Expense items amount is lesser than Expense total amount"
        )

      items_amount > total_amount ->
        add_error(
          changeset,
          :total_amount,
          "Expense items amount is greater than Expense total amount"
        )

      true ->
        changeset
    end
  end

  defp validate_total_amount(changeset, _expense) do
    changeset
  end

  defp total_amount(expense, changeset) do
    IO.inspect(changeset, label: "changeset")

    case changeset do
      %{changes: %{total_amount: total_amount}} ->
        total_amount

      _ ->
        expense.total_amount
    end
  end
end
