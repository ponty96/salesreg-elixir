defmodule SalesReg.Repo.Migrations.CreateDeliveryFee do
  use Ecto.Migration

  def change do
    create table(:delivery_fees, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:fee, :string)
      add(:state, :string)
      add(:region, :string)

      add(:company_id, references(:companies, on_delete: :nothing, type: :binary_id))
      add(:user_id, references(:users, on_delete: :nothing, type: :binary_id))

      timestamps()
    end

    create(index(:delivery_fees, [:company_id]))
    create unique_index(:delivery_fees, [:state, :region], name: :state_region_index)
  end
end
