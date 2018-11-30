defmodule SalesReg.Repo.Migrations.UpdateProductSchema do
  use Ecto.Migration

  def change do
    alter table(:products) do
      remove(:pack_quantity)
      remove(:price_per_pack)
      remove(:unit_quantity)

      add(:sku, :string)
      add(:minimum_sku, :string)
      add(:cost_price, :string)

      add :featured_image, :string
      add(:images, {:array, :string})
    end
  end
end
