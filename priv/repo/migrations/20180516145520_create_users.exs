defmodule SalesReg.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:first_name, :string)
      add(:last_name, :string)
      add(:gender, :string)
      add(:profile_pciture, :string)
      add(:date_of_birth, :string)
      add(:email, :string)
      add(:hashed_password, :string)

      timestamps()
    end
  end
end
