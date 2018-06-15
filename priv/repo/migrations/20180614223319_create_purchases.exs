defmodule SalesReg.Repo.Migrations.CreatePurchases do
  use Ecto.Migration

  def change do
    create table(:purchases, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :string
      add :purchasing_agent, :string
      add :date, :string
      add :payment_method, :string
      add :amount, :string

      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :vendor_id, references(:vendors, on_delete: :nothing, type: :binary_id)

      timestamps()
    end
    create index(:purchases, [:user_id, :vendor_id])
  end
end
