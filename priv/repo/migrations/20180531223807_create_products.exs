defmodule SalesReg.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string)
      add(:pack_quantity, :string)
      add(:price_per_pack, :string)
      add(:unit_quantity, :string)
      add(:selling_price, :string)
      add(:description, :string)
      add(:company_id, references(:companies, on_delete: :nothing, type: :binary_id))
      add(:user_id, references(:users, on_delete: :nothing, type: :binary_id))

      timestamps()
    end

    create(index(:products, [:company_id]))
    create(index(:products, [:user_id]))
  end
end
