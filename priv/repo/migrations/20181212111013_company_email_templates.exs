defmodule SalesReg.Repo.Migrations.CompanyEmailTemplates do
  use Ecto.Migration

  def change do
    create table(:company_email_templates, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:body, :text)
      add(:type, :string)

      add(:sale_id, references(:sales, type: :binary_id))
      add(:company_id, references(:companies, type: :binary_id))
    end

    create(index(:company_email_templates, [:sale_id], on_delete: :nothing, type: :binary_id))
    create(unique_index(:company_email_templates, [:type, :company_id], on_delete: :nothing, type: :binary_id))
  end
end
