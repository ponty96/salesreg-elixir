defmodule SalesReg.Repo.Migrations.AddFieldToItem do
  use Ecto.Migration

  def change do
    alter table(:items) do
      add(:sale_id, references(:sales, on_delete: :nothing, type: :binary_id))
    end

    create(index(:items, [:sale_id]))
  end
end
