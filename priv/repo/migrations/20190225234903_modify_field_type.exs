defmodule SalesReg.Repo.Migrations.ModifyFieldType do
  use Ecto.Migration

  def change do
    alter table(:products) do
      modify(:description, :text)
    end

    alter table(:companies) do
      modify(:description, :text)
    end
  end
end
