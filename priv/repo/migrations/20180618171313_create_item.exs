defmodule SalesReg.Repo.Migrations.CreateItem do
  use Ecto.Migration

  def change do
    create table(:items, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:quantity, :string)
      add(:unit_price, :string)

      add(:purchase_id, references(:purchases, on_delete: :nothing, type: :binary_id))
      add(:sale_id, references(:sales, on_delete: :nothing, type: :binary_id))

      add(:product_id, references(:products, on_delete: :nothing, type: :binary_id))
      add(:service_id, references(:services, on_delete: :nothing, type: :binary_id))

      timestamps()
    end

    create(index(:items, [:purchase_id]))
    create(index(:items, [:sale_id]))
    create(index(:items, [:product_id]))
    create(index(:items, [:service_id]))
  end
end
