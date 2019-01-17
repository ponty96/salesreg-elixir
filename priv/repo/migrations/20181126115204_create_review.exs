defmodule SalesReg.Repo.Migrations.CreateReview do
  use Ecto.Migration

  def change do
    create table(:review, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:text, :string)

      add(:sale_id, references(:sales, type: :binary_id))
      add(:product_id, references(:products, type: :binary_id))
      add(:contact_id, references(:contacts, type: :binary_id))
      add(:company_id, references(:companies, type: :binary_id))

      timestamps()
    end

    create(index(:reviews, [:sale_id], on_delete: :nothing, type: :binary_id))
    create(index(:reviews, [:contact_id], on_delete: :nothing, type: :binary_id))
    create(index(:reviews, [:product_id], on_delete: :nothing, type: :binary_id))
    create(index(:reviews, [:company_id], on_delete: :nothing, type: :binary_id))
  end
end
