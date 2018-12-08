defmodule SalesReg.Repo.Migrations.CreateCompanyTemplate do
  use Ecto.Migration

  def change do
    create table(:template, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:status, :string)
    
      add(:template_id, references(:templates, type: :binary_id))
      add(:user_id, references(:users, type: :binary_id))
      add(:company_id, references(:companies, type: :binary_id))

      timestamps()
    end

    create(index(:invoices, [:template_id], on_delete: :nothing, type: :binary_id))
    create(index(:invoices, [:user_id], on_delete: :nothing, type: :binary_id))
    create(index(:invoices, [:company_id], on_delete: :nothing, type: :binary_id))
  end
end
