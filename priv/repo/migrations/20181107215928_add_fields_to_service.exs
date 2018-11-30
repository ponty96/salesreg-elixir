defmodule SalesReg.Repo.Migrations.AddFieldsToService do
  use Ecto.Migration

  def change do
    alter table(:services) do
      add :featured_image, :string
      add(:images, {:array, :string})
      add(:is_featured, :boolean)
      add(:is_top_rated_by_merchant, :boolean) 
    end
  end
end
