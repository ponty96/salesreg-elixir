defmodule SalesReg.Repo.Migrations.CreateDeliveryDate do
  use Ecto.Migration

  def change do
    create table(:delivery_dates, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:date, :string)
      add(:confirmed, :boolean, default: false)

      add(:sale_id, references(:sales, on_delete: :nothing,type: :binary_id))
      add(:company_id, references(:companies, on_delete: :nothing, type: :binary_id))
      add(:user_id, references(:users, on_delete: :nothing, type: :binary_id))

      timestamps()
    end

    create(index(:delivery_dates, [:sale_id]))
    create(index(:delivery_dates, [:user_id]))
    create(index(:delivery_dates, [:company_id]))
  end
end
