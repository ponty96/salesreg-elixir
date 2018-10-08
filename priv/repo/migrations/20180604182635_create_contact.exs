defmodule SalesReg.Repo.Migrations.CreateContact do
  use Ecto.Migration

  def change do
    create table(:contacts, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:image, :string)
      add(:contact_name, :string)
      add(:phone1, :string)
      add(:phone2, :string)
      add(:residential_add, :string)
      add(:office_add, :string)
      add(:email, :string)
      add(:fax, :string)
      add(:allows_marketing, :string)


      add(:instagram, :string)
      add(:twitter, :string)
      add(:facebook, :string)
      add(:snapchat, :string)

      add(:gender, :string)

      add(:company_id, references(:companies, on_delete: :nothing, type: :binary_id))
      add(:user_id, references(:users, on_delete: :nothing, type: :binary_id))

      timestamps()
    end

    create(index(:contacts, [:user_id]))
    create(index(:contacts, [:company_id]))
  end
end
