defmodule SalesReg.Repo.Migrations.ChangeStringFieldsToDate do
  use Ecto.Migration

  def change do
    execute("""
      ALTER TABLE expenses
      ALTER COLUMN date TYPE date USING date::date;
    """)

    execute("""
      ALTER TABLE receipts
      ALTER COLUMN time_paid TYPE date USING time_paid::date;
    """)

    execute("""
      ALTER TABLE invoices
      ALTER COLUMN due_date TYPE date USING due_date::date;
    """)

    execute("""
      ALTER TABLE sales
      ALTER COLUMN date TYPE date USING date::date;
    """)
  end
end
