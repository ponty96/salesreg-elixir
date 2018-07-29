defmodule SalesReg.Repo.Migrations.CreatePhones do
  use Ecto.Migration

  def change do
    create table(:phones, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:type, :string)
      add(:number, :string)

      add :customer_id, references(:customers, on_delete: :nothing, type: :binary_id)
      add :user_id, references(:users, on_delete: :nothing, null: false, type: :binary_id)
      timestamps()
    end
    create index(:phones, [:customer_id, :user_id])
  end
end
