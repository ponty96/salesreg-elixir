defmodule SalesReg.Repo.Migrations.CreateCategory do
  use Ecto.Migration

  def change do
    create table(:categories, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:title, :string)
      add(:description, :string)
    end

    create table(:products_categories, primary_key: false) do
      add :product_id, references(:products, type: :binary_id)
      add :category_id, references(:categories, type: :binary_id)
    end

    create table(:services_categories, primary_key: false) do
      add :services_id, references(:services, type: :binary_id)
      add :category_id, references(:categories, type: :binary_id)
    end
  end
end
