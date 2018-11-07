defmodule SalesReg.Repo.Migrations.AddFieldsToService do
  use Ecto.Migration

  def change do
    alter table(:services) do
      add :featured_image, :string
      add(:images, {:array, :string})
    end
  end
end
