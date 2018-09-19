defmodule SalesReg.Repo.Migrations.CreateExpenseItem do
  use Ecto.Migration

  def change do
    create table(:expense_items, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:item_name, :string)
      add(:amount, :decimal, precision: 10, scale: 2)

      add(:expense_id, references(:expenses, on_delete: :nothing, type: :binary_id))
      timestamps()
    end

    create(index(:expense_items, [:expense_id]))
  end
end
