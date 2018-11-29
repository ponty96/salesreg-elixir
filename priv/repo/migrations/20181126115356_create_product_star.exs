defmodule SalesReg.Repo.Migrations.CreateProductStar do
  use Ecto.Migration

  def change do
    create table(:star, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:value, :integer)

      add(:sale_id, references(:sales, type: :binary_id))
      add(:product_id, references(:products, type: :binary_id))
      add(:service_id, references(:services, type: :binary_id))
      add(:contact_id, references(:contacts, type: :binary_id))

      timestamps()
    end

    create(unique_index(:star, [:sale_id, :contact_id, :product_id], on_delete: :nothing, type: :binary_id))
  end 
end
