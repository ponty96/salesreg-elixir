defmodule SalesReg.Repo.Migrations.ModifyStringFieldsToDecimal do
  use Ecto.Migration

  def change do
    execute(
      """
        ALTER TABLE activities
        ALTER COLUMN amount TYPE numeric USING amount::numeric(10,2);
      """
    )

    execute(
      """
        ALTER TABLE delivery_fees
        ALTER COLUMN fee TYPE numeric USING fee::numeric(10,2);
      """
    )

    execute(
      """
        ALTER TABLE items
        ALTER COLUMN quantity TYPE numeric USING quantity::numeric(10,2),
        ALTER COLUMN unit_price TYPE numeric USING unit_price::numeric(10,2);
      """
    )

    execute(
      """
        ALTER TABLE receipts
        ALTER COLUMN amount_paid TYPE numeric USING amount_paid::numeric(10,2);
      """
    )

    execute(
      """
        ALTER TABLE sales
        ALTER COLUMN tax TYPE numeric USING tax::numeric(10,2),
        ALTER COLUMN discount TYPE numeric USING discount::numeric(10,2),
        ALTER COLUMN charge TYPE numeric USING charge::numeric(10,2),
        ALTER COLUMN delivery_fee DROP DEFAULT,
        ALTER COLUMN delivery_fee TYPE numeric USING delivery_fee::numeric(10,2),
        ALTER COLUMN delivery_fee SET DEFAULT 0.0;
      """
    )

    execute(
      """
        ALTER TABLE bonanza_items
        ALTER COLUMN price_slash_to TYPE numeric USING price_slash_to::numeric(10,2),
        ALTER COLUMN max_quantity TYPE numeric USING max_quantity::numeric(10,2);
      """
    )

    execute(
      """
        ALTER TABLE products
        ALTER COLUMN sku TYPE numeric USING sku::numeric(10,2),
        ALTER COLUMN minimum_sku TYPE numeric USING minimum_sku::numeric(10,2),
        ALTER COLUMN cost_price TYPE numeric USING cost_price::numeric(10,2),
        ALTER COLUMN price TYPE numeric USING price::numeric(10,2);
      """
    )
  end
end
