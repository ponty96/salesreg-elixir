defmodule SalesReg.Repo.Migrations.RemoveFieldsFromCustomer do
  use Ecto.Migration

  def change do
    alter table(:customers) do
      remove(:phone1)
      remove(:phone2)
      remove(:residential_add)
      remove(:office_add)
    end
  end
end
