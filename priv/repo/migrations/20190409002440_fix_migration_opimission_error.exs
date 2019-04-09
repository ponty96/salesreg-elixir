defmodule SalesReg.Repo.Migrations.FixMigrationOpimissionError do
  use Ecto.Migration

  def change do
    execute(
      """
        ALTER TABLE items
        ALTER COLUMN quantity TYPE int USING quantity::int;
      """
    )

    execute(
      """
        ALTER TABLE bonanza_items
        ALTER COLUMN max_quantity TYPE int USING max_quantity::int;
      """
    )

    execute(
      """
        ALTER TABLE products
        ALTER COLUMN sku TYPE int USING sku::int,
        ALTER COLUMN minimum_sku TYPE int USING minimum_sku::int;
      """
    )
  end
end
