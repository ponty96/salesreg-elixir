defmodule SalesReg.Repo.Migrations.CreateCategory do
  use Ecto.Migration

  def change do
    create table(:categories, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:title, :string)
      add(:description, :string)

      add(:company_id, references(:companies, on_delete: :nothing, type: :binary_id))
      add(:user_id, references(:users, on_delete: :nothing, type: :binary_id))

      timestamps()
    end

    create table(:products_categories, primary_key: false) do
      add(:product_id, references(:products, type: :binary_id, on_delete: :delete_all))
      add(:category_id, references(:categories, type: :binary_id, on_delete: :delete_all))
    end

    create(index(:categories, [:company_id]))
    create(index(:categories, [:user_id]))

    create(unique_index(:products_categories, [:product_id, :category_id]))
  end
end
