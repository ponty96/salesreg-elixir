defmodule SalesReg.Repo.Migrations.AddLocationToSales do
  use Ecto.Migration

  def change do
    alter table(:sales) do
      add(:location_id, references(:locations, on_delete: :nothing, type: :binary_id))
      
    end

    create(index(:sales, [:location_id]))
  end
end
