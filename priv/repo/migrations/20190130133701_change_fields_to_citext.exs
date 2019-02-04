defmodule SalesReg.Repo.Migrations.ChangeFieldsToCitext do
  use Ecto.Migration

  def change do
    
    alter table(:companies) do
      modify :contact_email, :citext
      modify :slug, :citext
    end

    alter table(:users) do
      modify :email, :citext
    end

  end
end
