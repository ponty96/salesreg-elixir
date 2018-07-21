defmodule SalesReg.Repo.Migrations.AddFieldsToLocations do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add(:type, :string)
      add(:vendor_id, references(:vendors, on_delete: :nothing, type: :binary_id))
    end

    create(index(:locations, [:vendor_id]))
  end
end
