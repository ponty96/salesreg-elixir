defmodule SalesReg.Repo.Migrations.CreateBank do
  use Ecto.Migration

  def change do
    create table(:banks, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:account_name, :string)
      add(:account_number, :string)
      add(:bank_name, :string)

      timestamps()
    end
  end
end
