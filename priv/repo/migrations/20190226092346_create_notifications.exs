defmodule SalesReg.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:element, :string)
      add(:element_id, :string)
      add(:action_type, :string)
      add(:delivery_channel, :string)
      add(:delivery_status, :string)
      add(:read_status, :string)
      add(:company_id, references(:companies, on_delete: :nothing, type: :binary_id))
      add(:actor_id, references(:users, on_delete: :nothing, type: :binary_id))

      timestamps()
    end

    create(index(:notifications, [:company_id]))
    create(index(:notifications, [:actor_id]))
  end
end
