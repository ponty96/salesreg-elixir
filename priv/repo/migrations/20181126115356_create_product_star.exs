defmodule SalesReg.Repo.Migrations.CreateProductStar do
  use Ecto.Migration

  def change do
    create table(:stars, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:value, :integer)

      add(:sale_id, references(:sales, type: :binary_id))
      add(:product_id, references(:products, type: :binary_id))
      add(:contact_id, references(:contacts, type: :binary_id))
      add(:company_id, references(:companies, type: :binary_id))

      timestamps()
    end

    create(index(:stars, [:sale_id], on_delete: :nothing, type: :binary_id))
    create(index(:stars, [:contact_id], on_delete: :nothing, type: :binary_id))
    create(index(:stars, [:product_id], on_delete: :nothing, type: :binary_id))
    create(index(:stars, [:company_id], on_delete: :nothing, type: :binary_id))
  end
end
