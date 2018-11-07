defmodule SalesReg.Repo.Migrations.CreateReceipts do
  use Ecto.Migration

  def change do
    create table(:receipts, primary_key: false) do
      add(:id, :binary_id)
      add(:time_paid, :string)
      add(:amount_paid, :string)
      add(:payment_method, :string)

      add(:invoice_id, references(:invoices))
      add(:user_id, references(:users))
      add(:company_id, references(:companies))

      timestamps()
    end

    create(index(:receipts, [:invoice_id], on_delete: :nothing, type: :binary_id)))
    create(index(:receipts, [:user_id], on_delete: :nothing, type: :binary_id)))
    create(index(:receipts, [:company_id], on_delete: :nothing, type: :binary_id)))
  end
end
