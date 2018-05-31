defmodule SalesReg.Repo.Migrations.CreateEmployees do
  use Ecto.Migration

  def change do
    create table(:employees, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :employer_id, references(:companies, on_delete: :nothing, type: :binary_id)
      add :person_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :branch_id, references(:branches, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:employees, [:employer_id])
    create index(:employees, [:person_id])
    create index(:employees, [:branch_id])
  end
end
