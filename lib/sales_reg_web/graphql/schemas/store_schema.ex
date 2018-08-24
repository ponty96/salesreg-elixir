defmodule SalesRegWeb.GraphQL.Schemas.StoreSchema do
  @moduledoc """
    GraphQL Schemas for Store
  """
  use Absinthe.Schema.Notation
  alias SalesRegWeb.GraphQL.Resolvers.StoreResolver
  alias SalesRegWeb.GraphQL.MiddleWares.Authorize

  ### MUTATIONS
  object :product_mutations do
    @desc """
    upsert a product in a company's store
    """
    field :upsert_product, :mutation_response do
      arg(:product, non_null(:product_input))
      arg(:product_id, :uuid)

      middleware(Authorize)
      resolve(&StoreResolver.upsert_product/2)
    end
  end

  object :service_mutations do
    @desc """
    upsert a product in a company's store
    """
    field :upsert_service, :mutation_response do
      arg(:service, non_null(:service_input))
      arg(:service_id, :uuid)

      middleware(Authorize)
      resolve(&StoreResolver.upsert_service/2)
    end
  end

  ### QUERIES
  ## Product queries
  object :product_queries do
    @desc """
      query for all products in a company's store
    """
    field :list_company_products, list_of(:product) do
      arg(:company_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&StoreResolver.list_company_products/2)
    end
  end

  ## Service queries
  object :service_queries do
    @desc """
      query for all services in a company's store
    """
    field :list_company_services, list_of(:service) do
      arg(:company_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&StoreResolver.list_company_services/2)
    end

    @desc """
      search for services by name
    """
    field :search_services_by_name, list_of(:search_response) do
      arg(:query, non_null(:string))

      # middleware(Authorize)
      resolve(&StoreResolver.search_services_by_name/2)
    end
  end
end
