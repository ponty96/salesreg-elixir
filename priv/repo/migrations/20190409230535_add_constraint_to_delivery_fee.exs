defmodule SalesReg.Repo.Migrations.AddConstraintToDeliveryFee do
  use Ecto.Migration

  def change do
    drop unique_index(:delivery_fees, [:state, :region], name: :state_region_index)
    create unique_index(:delivery_fees, [:company_id, :state, :region], name: :company_state_region_index)
  end
end