defmodule SalesReg.Repo.Migrations.AddSalesToLocation do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add(:sale_id, references(:sales, on_delete: :nothing, type: :binary_id))
    end

    create(index(:locations, [:sale_id]))
  end
end
