defmodule SalesReg.Repo.Migrations.CreateLegalDocument do
  use Ecto.Migration

  def change do
    create table(:legal_documents, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string)
      add(:type, :string)
      add(:content, :string)
      add(:pdf_url, :string)

      add(:company_id, references(:companies, type: :binary_id))

      timestamps()
    end

    create(index(:legal_documents, [:company_id], on_delete: :nothing, type: :binary_id))
  end
end
