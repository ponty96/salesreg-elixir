defmodule SalesReg.Repo.Migrations.CreateCompanyTemplate do
  use Ecto.Migration

  def change do
    create table(:company_templates, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:status, :string)

      add(:template_id, references(:templates, type: :binary_id))
      add(:user_id, references(:users, type: :binary_id))
      add(:company_id, references(:companies, type: :binary_id))

      timestamps()
    end

    create(index(:company_templates, [:template_id], on_delete: :nothing, type: :binary_id))
    create(index(:company_templates, [:user_id], on_delete: :nothing, type: :binary_id))
    create(unique_index(:company_templates, [:company_id], on_delete: :nothing, type: :binary_id))
  end
end
