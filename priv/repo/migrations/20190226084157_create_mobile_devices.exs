defmodule SalesReg.Repo.Migrations.CreateMobileDevices do
  use Ecto.Migration

  def change do
    create table(:mobile_devices, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:mobile_os, :string)
      add(:brand, :string)
      add(:build_number, :string)
      add(:device_token, :string)
      add(:app_version, :string)
      add(:notification_enabled, :string)
      add(:last_active, :string)
      add(:user_id, references(:users, on_delete: :nothing, type: :binary_id))

      timestamps()
    end

    create(index(:mobile_devices, [:user]))
  end
end
