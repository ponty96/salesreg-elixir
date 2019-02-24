defmodule SalesReg.Repo.Migrations.RemoveAllowsSplitPaymentFieldToInvoice do
  use Ecto.Migration

  def change do
    alter table(:invoices) do
      remove(:allows_split_payment)
    end
  end
end
