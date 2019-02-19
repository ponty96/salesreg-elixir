defmodule SalesReg.Repo.Migrations.CreateBonanza do
  use Ecto.Migration

  def change do
    create table(:bonanzas, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:title, :string)
      add(:cover_photo, :string)
      add(:start_date, :string)
      add(:end_date, :string)
      add(:slug, :string)
      add(:description, :text)

      add(:company_id, references(:companies, on_delete: :nothing, type: :binary_id))
      add(:user_id, references(:users, on_delete: :nothing, type: :binary_id))

      timestamps()
    end

    create(index(:bonanzas, [:company_id]))
    create(index(:bonanzas, [:user_id]))
    create(unique_index(:bonanzas, [:slug]))
  end
end
