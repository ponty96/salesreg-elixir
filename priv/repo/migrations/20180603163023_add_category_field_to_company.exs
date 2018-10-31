defmodule SalesReg.Repo.Migrations.AddCategoryFieldToCompany do
  use Ecto.Migration

  def change do
    alter table(:companies) do
      add(:category, :string)
      remove(:category)
    end
  end
end
