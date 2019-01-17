defmodule SalesReg.Repo.Migrations.AddCompanyIdToReview do
  use Ecto.Migration

  def change do
    alter table(:tables) do
      add(:company_id, references(:companies, type: :binary_id))
    end

    create(index(:review, [:company_id], on_delete: :nothing, type: :binary_id))
  end
end
