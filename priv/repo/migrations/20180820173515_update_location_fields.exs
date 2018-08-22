defmodule SalesReg.Repo.Migrations.UpdateLocationFields do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      remove(:residential_add_id)
      remove(:office_add_id)
      add(:contact_id, references(:contacts, on_delete: :nothing, type: :binary_id))
    end

    create(index(:locations, [:contact_id]))
  end
end
