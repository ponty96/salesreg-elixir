defmodule SalesReg.Repo.Migrations.UpdateCustomerFields do
  use Ecto.Migration

  def change do
    alter table(:customers) do
      remove(:fax)
    end
  end
end
