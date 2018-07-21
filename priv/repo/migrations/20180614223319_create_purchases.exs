defmodule SalesReg.Repo.Migrations.CreatePurchase do
  use Ecto.Migration

  def change do
    create table(:purchases, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:status, :string, default: "pending", null: false)
      add(:purchasing_agent, :string)
      add(:date, :string)
      add(:payment_method, :string)
      add(:amount, :string)

      add(:user_id, references(:users, on_delete: :nothing, type: :binary_id))
      add(:vendor_id, references(:vendors, on_delete: :nothing, type: :binary_id))
      add(:company_id, references(:companies, on_delete: :nothing, type: :binary_id))

      timestamps()
    end

    create(index(:purchases, [:user_id, :vendor_id, :company_id]))
  end
end
