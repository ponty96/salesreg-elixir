defmodule SalesReg.Repo.Migrations.AddFieldsToCustomer do
  use Ecto.Migration

  def change do
    alter table(:customers) do
      add(:currency, :string)
      add(:birthday, :string)
      add(:marital_status, :string)
      add(:marriage_anniversary, :string)
      add(:likes, {:array, :string})
      add(:dislikes, {:array, :string})
    end
  end
end