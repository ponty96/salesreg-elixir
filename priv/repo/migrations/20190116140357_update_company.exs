defmodule SalesReg.Repo.Migrations.UpdateCompany do
  use Ecto.Migration

  def change do
    alter table(:companies) do
      remove(:description)
      add(:description, :text)
    end
  end
end
