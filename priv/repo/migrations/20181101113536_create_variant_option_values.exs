defmodule SalesReg.Repo.Migrations.CreateOptionValues do
  use Ecto.Migration

  def change do
    create table(:option_values, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string)
      add(:company_id, references(:companies, on_delete: :nothing, type: :binary_id))
      add(:option_id, references(:options, on_delete: :delete_all, type: :binary_id))

      add(:product_id, references(:products, type: :binary_id, on_delete: :delete_all))

      timestamps()
    end

    create(index(:option_values, [:company_id]))
    create(index(:option_values, [:option_id]))
  end
end
