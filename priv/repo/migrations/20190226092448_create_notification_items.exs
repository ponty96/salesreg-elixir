defmodule SalesReg.Repo.Migrations.CreateNotificationItems do
  use Ecto.Migration

  def change do
    create table(:notification_items, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:item_type, :string)
      add(:current, :string)
      add(:changed_to, :string)
      field(:item_id, :string)
      add(:notification_id, references(:notifications, on_delete: :nothing, type: :binary_id))

      timestamps()
    end

    create(index(:notification_items, [:notification]))
    create(index(:notification_items, [:item_type, :item_id]))
  end
end
