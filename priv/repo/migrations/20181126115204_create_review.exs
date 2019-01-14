defmodule SalesReg.Repo.Migrations.CreateReview do
  use Ecto.Migration

  def change do
    create table(:review, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:text, :string)

      add(:sale_id, references(:sales, type: :binary_id))
      add(:product_id, references(:products, type: :binary_id))
      add(:contact_id, references(:contacts, type: :binary_id))

      timestamps()
    end

    create(index(:review, [:sale_id], on_delete: :nothing, type: :binary_id))
    create(index(:review, [:contact_id], on_delete: :nothing, type: :binary_id))
    create(index(:review, [:product_id], on_delete: :nothing, type: :binary_id))
  end
end
