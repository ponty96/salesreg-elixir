defmodule SalesReg.Repo.Migrations.AddManyToManyRelationships do
  use Ecto.Migration

  def change do
    create table(:product_groups_options, primary_key: false) do
      add(
        :product_group_id,
        references(:product_groups, type: :binary_id, on_delete: :delete_all)
      )

      add(:option_id, references(:options, type: :binary_id, on_delete: :delete_all))
    end

    alter table(:products) do
      add(
        :product_group_id,
        references(:product_groups, on_delete: :nothing, type: :binary_id)
      )
    end

    create(unique_index(:product_groups_options, [:product_group_id, :option_id]))
    create(unique_index(:products_option_values, [:product_id, :option_value_id]))
    create(index(:products, [:product_group_id]))
  end
end
