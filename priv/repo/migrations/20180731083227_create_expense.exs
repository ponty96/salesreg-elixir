defmodule SalesReg.Repo.Migrations.CreateExpense do
  use Ecto.Migration

  def change do
    create table(:expenses, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:title, :string)
      add(:date, :string)
      add(:total_amount, :string)
      add(:payment_method, :string)
      
      add(:paid_by_id, references(:users, on_delete: :nothing, type: :binary_id))
      add(:paid_to_id, references(:users, on_delete: :nothing, type: :binary_id))
      add(:company_id, references(:companies, on_delete: :nothing, type: :binary_id))

      timestamps()
    end
    create(index(:expenses, [:paid_by_id, :paid_to_id, :company_id]))
  end
end
