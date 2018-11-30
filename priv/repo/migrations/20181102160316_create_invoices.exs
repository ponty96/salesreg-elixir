defmodule SalesReg.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:invoices, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:due_date, :string)
      add(:pdf_url, :string)

      add(:sale_id, references(:sales, type: :binary_id))
      add(:user_id, references(:users, type: :binary_id))
      add(:company_id, references(:companies, type: :binary_id))

      timestamps()
    end

    create(index(:invoices, [:sale_id], on_delete: :nothing, type: :binary_id))
    create(index(:invoices, [:user_id], on_delete: :nothing, type: :binary_id))
    create(index(:invoices, [:company_id], on_delete: :nothing, type: :binary_id))
  end
end
