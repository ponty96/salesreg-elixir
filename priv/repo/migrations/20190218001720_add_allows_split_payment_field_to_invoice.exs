defmodule SalesReg.Repo.Migrations.AddAllowsSplitPaymentFieldToInvoice do
  use Ecto.Migration

  def change do
    alter table(:invoices) do
      add(:allows_split_payment, :boolean)
    end
  end
end
