defmodule SalesReg.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:lat, :string)
      add(:long, :string)
      add(:street1, :string)
      add(:street2, :string)
      add(:city, :string)
      add(:state, :string)
      add(:country, :string)
      add(:branch_id, references(:branches, on_delete: :nothing, type: :binary_id))

      timestamps()
    end

    create(index(:locations, [:branch_id]))
  end
end
