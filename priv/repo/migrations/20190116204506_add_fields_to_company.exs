defmodule SalesReg.Repo.Migrations.AddFieldsToCompany do
  use Ecto.Migration

  def change do
    alter table(:companies) do
      add(:facebook, :string)
      add(:twitter, :string)
      add(:instagram, :string)
      add(:linkedIn, :string)
    end
  end
end
