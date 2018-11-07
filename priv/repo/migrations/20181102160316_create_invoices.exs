defmodule SalesReg.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:invoices, primary_key: false) do
      add(:id, :binary_id)
      add(:due_date, :string)

      add(:sale_id, references(:sales))
      add(:user_id, references(:users))
      add(:company_id, references(:companies))
      
      timestamps()
    end

    create(index(:invoices, [:sale_id], on_delete: :nothing, type: :binary_id))
    create(index(:invoices, [:user_id], on_delete: :nothing, type: :binary_id))
    create(index(:invoices, [:company_id], on_delete: :nothing, type: :binary_id))
  end
end
