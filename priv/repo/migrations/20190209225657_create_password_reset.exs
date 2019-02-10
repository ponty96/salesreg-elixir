defmodule SalesReg.Repo.Migrations.CreatePasswordReset do
  use Ecto.Migration

  def change do
    create table(:companies, primary_key: false) do
      add(:user_id, references(:users, on_delete: :nothing, type: :binary_id))

      timestamps()
    end

    create(index(:users, [:user_id]))
  end
end
