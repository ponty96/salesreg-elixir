defmodule SalesReg.Repo.Migrations.AddSlugToProducts do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add(:slug, :string)
    end

    create(unique_index(:products, [:slug]))
  end
end
