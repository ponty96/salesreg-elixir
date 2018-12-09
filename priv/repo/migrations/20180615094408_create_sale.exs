defmodule SalesReg.Repo.Migrations.CreateSale do
  use Ecto.Migration

  def change do
    create table(:sales, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:status, :string, default: "pending", null: false)
      add(:payment_method, :string)
      add(:tax, :string)
      add(:date, :string)
      add(:discount, :string)

      add(:user_id, references(:users, on_delete: :nothing, type: :binary_id))
      add(:contact_id, references(:contacts, on_delete: :nothing, type: :binary_id))
      add(:company_id, references(:companies, on_delete: :nothing, type: :binary_id))

      timestamps()
    end

    create(index(:sales, [:user_id, :contact_id, :company_id]))
  end
end
