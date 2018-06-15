defmodule SalesReg.Repo.Migrations.CreateItem do
  use Ecto.Migration

  def change do
    create table(:items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :quantity, :string
      add :unit_price, :string
      
      add :purchase_id, references(:purchases, on_delete: :nothing, type: :binary_id)

      timestamps()
    end
    create index(:items, [:purchase_id])
  end
end
