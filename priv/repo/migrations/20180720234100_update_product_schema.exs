defmodule SalesReg.Repo.Migrations.UpdateProductSchema do
  use Ecto.Migration

  def change do
    alter table(:products) do
      remove(:pack_quantity)
      remove(:price_per_pack)
      remove(:unit_quantity)

      add(:stock_quantity, :string)
      add(:minimum_stock_quantity, :string)
      add(:cost_price, :string)
    end
  end
end
