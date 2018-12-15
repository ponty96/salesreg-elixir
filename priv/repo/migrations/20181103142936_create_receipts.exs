defmodule SalesReg.Repo.Migrations.CreateReceipts do
  use Ecto.Migration

  def change do
    create table(:receipts, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:time_paid, :string)
      add(:amount_paid, :string)
      add(:payment_method, :string)
      add(:pdf_url, :string)
      add(:transaction_id, :integer)

      add(:invoice_id, references(:invoices, type: :binary_id))
      add(:user_id, references(:users, type: :binary_id))
      add(:company_id, references(:companies, type: :binary_id))
      add(:sale_id, references(:sales, type: :binary_id))

      timestamps()
    end

    create(index(:receipts, [:invoice_id], on_delete: :nothing, type: :binary_id))
    create(index(:receipts, [:user_id], on_delete: :nothing, type: :binary_id))
    create(index(:receipts, [:company_id], on_delete: :nothing, type: :binary_id))
  end
end
