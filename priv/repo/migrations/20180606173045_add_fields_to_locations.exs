defmodule SalesReg.Repo.Migrations.AddFieldsToLocations do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add(:type, :string)
      add(:contact_id, references(:contacts, on_delete: :nothing, type: :binary_id))
    end

    create(index(:locations, [:contact_id]))
  end
end
