defmodule SalesRegWeb.GraphQL.Schemas.StoreSchema do
  @moduledoc """
    GraphQL Schemas for Store
  """
  use Absinthe.Schema.Notation
  alias SalesRegWeb.GraphQL.Resolvers.StoreResolver

  object :product_mutations do
    @desc """
    add a product in a company's store
    """
    field :add_product, :mutation_response do
      arg(:product, non_null(:product_input))

      resolve(&StoreResolver.add_product/2)
    end

    @desc """
    update a product in a company's store
    """
    field :update_product, :mutation_response do
      arg(:product, non_null(:product_input))
      arg(:product_id, non_null(:uuid))

      resolve(&StoreResolver.update_product/2)
    end
  end

  object :product_queries do
    @desc """
      query for all products in a company's store
    """
    field :list_company_products, list_of(:product) do
      arg(:company_id, non_null(:uuid))

      resolve(&StoreResolver.list_company_products/2)
    end
  end
end
