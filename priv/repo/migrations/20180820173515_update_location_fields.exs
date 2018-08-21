defmodule SalesReg.Repo.Migrations.UpdateLocationFields do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      remove(:residential_add_id)
      remove(:office_add_id)
      add(:customer_id, references(:customers, on_delete: :nothing, type: :binary_id))
    end
    create(index(:locations, [:customer_id]))
  end
end
