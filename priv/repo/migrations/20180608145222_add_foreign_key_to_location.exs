defmodule SalesReg.Repo.Migrations.AddForeignKeyToLocation do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      remove(:contact_id)
      add(:residential_add_id, references(:contacts, on_delete: :nothing, type: :binary_id))
      add(:office_add_id, references(:contacts, on_delete: :nothing, type: :binary_id))
    end

    create(index(:locations, [:residential_add_id, :office_add_id]))
  end
end
