defmodule SalesReg.Repo.Migrations.CreateCompanies do
  use Ecto.Migration

  def change do
    create table(:companies, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :contact_email, :string
      add :about, :string
      add :owner_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:companies, [:owner_id])
  end
end
