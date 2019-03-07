defmodule SalesReg.Repo.Migrations.RenameFieldInNotification do
  use Ecto.Migration

  def change do
    rename table(:notifications), :element_data, to: :message
  end
end
