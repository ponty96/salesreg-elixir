defmodule SalesReg.Repo.Migrations.AddFieldToPhones do
  use Ecto.Migration

  def change do
    create(unique_index(:phones, [:number]))
  end
end
