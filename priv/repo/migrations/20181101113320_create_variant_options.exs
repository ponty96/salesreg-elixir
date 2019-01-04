defmodule SalesReg.Repo.Migrations.CreateOptions do
  use Ecto.Migration

  def change do
    create table(:options, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string)
      add(:is_visual, :string)
      add(:company_id, references(:companies, on_delete: :nothing, type: :binary_id))

      timestamps()
    end

    create(index(:options, [:company_id]))
  end
end
