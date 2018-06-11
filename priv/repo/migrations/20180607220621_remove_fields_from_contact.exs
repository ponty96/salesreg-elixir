defmodule SalesReg.Repo.Migrations.RemoveFieldsFromContact do
  use Ecto.Migration

  def change do
    alter table(:contacts) do
      remove :phone1
      remove :phone2
      remove :residential_add
      remove :office_add
    end
  end
end
