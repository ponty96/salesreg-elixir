defmodule SalesReg.Repo.Migrations.CreateCompanies do
  use Ecto.Migration

  def change do
    create table(:companies, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:title, :string)
      add(:contact_email, :string)
      add(:about, :string)
      add(:owner_id, references(:users, on_delete: :nothing, type: :binary_id))
      add(:currency, :string)
      add(:description, :string)
      add(:logo, :string)
      add(:cover_photo, :string)

      timestamps()
    end

    create(unique_index(:companies, [:owner_id]))
  end
end
