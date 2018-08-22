defmodule SalesReg.Repo.Migrations.UpdateContactFields do
  use Ecto.Migration

  def change do
    alter table(:contacts) do
      remove(:fax)
      add(:type, :string)
    end
  end
end
