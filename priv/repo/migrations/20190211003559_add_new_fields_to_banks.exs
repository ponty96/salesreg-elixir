defmodule SalesReg.Repo.Migrations.AddNewFieldsToBanks do
  use Ecto.Migration

  def change do
    alter table(:banks) do
      add(:bank_code, :string)
      add(:subaccount_id, :string)
      add(:subaccount_transac_id, :string)
      remove(:is_primary)
    end
  end
end
