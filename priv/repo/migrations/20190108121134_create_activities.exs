defmodule SalesReg.Repo.Migrations.CreateActivities do
  use Ecto.Migration

  def change do
    create table(:activities, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:type, :string)
      add(:amount, :string)

      add(:sale_id, references(:sales, type: :binary_id))
      add(:invoice_id, references(:invoices, type: :binary_id))
      add(:contact_id, references(:contacts, type: :binary_id))
      add(:company_id, references(:companies, type: :binary_id))

      timestamps()
    end

    create(index(:activities, [:sale_id], on_delete: :nothing, type: :binary_id))
    create(index(:activities, [:invoice_id], on_delete: :nothing, type: :binary_id))
    create(index(:activities, [:contact_id], on_delete: :nothing, type: :binary_id))
    create(index(:activities, [:company_id], on_delete: :nothing, type: :binary_id))
  end
end
