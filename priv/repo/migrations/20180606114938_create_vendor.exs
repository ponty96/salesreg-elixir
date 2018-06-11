defmodule SalesReg.Repo.Migrations.CreateVendor do
  use Ecto.Migration

  def change do
    create table(:vendors, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string
      add :fax, :string
      add :city, :string
      add :state, :string
      add :country, :string
      add :currency, :string

      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :company_id, references(:companies, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:vendors, [:user_id])
    create index(:vendors, [:company_id])
    create unique_index(:vendors, [:email])
  end
end
