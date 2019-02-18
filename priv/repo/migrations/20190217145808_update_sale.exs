defmodule SalesReg.Repo.Migrations.UpdateSale do
  use Ecto.Migration

  def change do
    alter table(:sales) do
      add(:bonanza_id, references(:bonanzas, on_delete: :nothing, type: :binary_id))
    end

    create(index(:sales, [:bonanza_id]))
  end
end
