defmodule SalesReg.Repo.Migrations.CreateBonanzaItem do
  use Ecto.Migration

  def change do
    create table(:bonanza_items, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:price_slash_to, :string)
      add(:max_quantity, :string)

      add(:product_id, references(:products, on_delete: :nothing, type: :binary_id))

      timestamps()
    end

    create(index(:bonanza_items, [:product_id]))
  end
end
