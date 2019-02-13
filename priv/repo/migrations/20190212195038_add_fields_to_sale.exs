defmodule SalesReg.Repo.Migrations.AddFieldsToSale do
  use Ecto.Migration

  def change do
    alter table(:sales) do
      add(:charge, :string)
    end
  end
end
