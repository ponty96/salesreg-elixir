defmodule SalesReg.Repo.Migrations.AddFieldsToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:confirmed_email?, :boolean, default: false)
      add(:hashed_str, :string)
    end
  end
end
