defmodule SalesReg.Repo.Migrations.AddCategorySlug do
  use Ecto.Migration

  def change do
    alter table(:categories) do
      add(:slug, :string)
    end

    create(unique_index(:categories, [:slug]))
    create(unique_index(:categories, [:title, :company_id]))
  end
end
