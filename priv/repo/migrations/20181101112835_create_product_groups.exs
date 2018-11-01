defmodule SalesReg.Repo.Migrations.CreateProductGroups do
  use Ecto.Migration

  def change do
    create table(:product_groups, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :company_id, references(:companies, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:product_groups, [:company_id])
  end
end
