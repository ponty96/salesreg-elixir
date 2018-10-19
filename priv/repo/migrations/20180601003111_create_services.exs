defmodule SalesReg.Repo.Migrations.CreateServices do
  use Ecto.Migration

  def change do
    create table(:services, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string)
      add(:description, :string)
      add(:price, :string)
      add(:images, {:array, :string})
      add(:user_id, references(:users, on_delete: :nothing, type: :binary_id))
      add(:company_id, references(:companies, on_delete: :nothing, type: :binary_id))

      timestamps()
    end

    create(index(:services, [:user_id]))
    create(index(:services, [:company_id]))
  end
end
