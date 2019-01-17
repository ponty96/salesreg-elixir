defmodule SalesReg.Repo.Migrations.AddCompanyIdToStar do
  use Ecto.Migration

  def change do
    alter table(:stars) do
      add(:company_id, references(:companies, type: :binary_id))
    end

    create(index(:stars, [:company_id], on_delete: :nothing, type: :binary_id))
  end
end
