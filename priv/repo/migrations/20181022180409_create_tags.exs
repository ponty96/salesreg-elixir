defmodule SalesReg.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string)

      add(:company_id, references(:companies, on_delete: :nothing, type: :binary_id))

      timestamps()
    end

    create table(:products_tags, primary_key: false) do
      add(:product_id, references(:products, type: :binary_id, on_delete: :delete_all))
      add(:tag_id, references(:tags, type: :binary_id, on_delete: :delete_all))
    end

    create table(:services_tags, primary_key: false) do
      add(:service_id, references(:services, type: :binary_id, on_delete: :delete_all))
      add(:tag_id, references(:tags, type: :binary_id, on_delete: :delete_all))
    end

    create(index(:tags, [:company_id]))

    create(unique_index(:products_tags, [:product_id, :tag_id]))
    create(unique_index(:services_tags, [:service_id, :tag_id]))
  end
end
