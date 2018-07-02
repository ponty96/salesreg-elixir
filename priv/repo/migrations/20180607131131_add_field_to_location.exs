defmodule SalesReg.Repo.Migrations.AddFieldToLocation do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add :customer_id, references(:customers, on_delete: :nothing, type: :binary_id)
    end
    create index(:locations, [:customer_id])
  end
end
