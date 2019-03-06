defmodule SalesReg.Repo.Migrations.AddDeliveryFeeToSale do
  use Ecto.Migration

  def change do
    alter table(:sales) do
      add(:delivery_fee, :string)
    end
  end
end
