defmodule SalesRegWeb.GraphQL.Schemas.StoreSchema do
  @moduledoc """
    GraphQL Schemas for Store
  """
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :classic
  alias SalesRegWeb.GraphQL.Resolvers.StoreResolver
  alias SalesRegWeb.GraphQL.MiddleWares.Authorize

  ### MUTATIONS
  object :store_mutations do
    @desc """
    upsert a product in a company's store
    """
    field :upsert_product, :mutation_response do
      arg(:product, non_null(:product_input))
      arg(:product_id, :uuid)

      middleware(Authorize)
      resolve(&StoreResolver.upsert_product/2)
    end

    @desc """
      mutation to delete product
    """
    field :delete_product, :mutation_response do
      arg(:product_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&StoreResolver.delete_product/2)

    end

    @desc """
    upsert a service in a company's store
    """
    field :upsert_service, :mutation_response do
      arg(:service, non_null(:service_input))
      arg(:service_id, :uuid)

      middleware(Authorize)
      resolve(&StoreResolver.upsert_service/2)
    end

    @desc """
    mutation to delete service
  """
  field :delete_service, :mutation_response do
    arg(:service_id, non_null(:uuid))

    middleware(Authorize)
    resolve(&StoreResolver.delete_service/2)

  end

    @desc """
    upsert a category in a company's store
    """
    field :upsert_category, :mutation_response do
      arg(:category, non_null(:category_input))
      arg(:category_id, :uuid)

      middleware(Authorize)
      resolve(&StoreResolver.upsert_category/2)
    end
  end

  ### QUERIES
  object :store_queries do
    @desc """
      query for all products in a company's store
    """
    connection field :list_company_products, node_type: :product do
      arg(:company_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&StoreResolver.list_company_products/2)
    end

    @desc """
      search for products by name
    """
    field :search_products_by_name, list_of(:search_response) do
      arg(:query, non_null(:string))

      middleware(Authorize)
      resolve(&StoreResolver.search_products_by_name/2)
    end

    @desc """
      query for all services in a company's store
    """
    connection field :list_company_services, node_type: :service do
      arg(:company_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&StoreResolver.list_company_services/2)
    end

    @desc """
      search for services by name
    """
    field :search_services_by_name, list_of(:search_response) do
      arg(:query, non_null(:string))

      middleware(Authorize)
      resolve(&StoreResolver.search_services_by_name/2)
    end

    @desc """
      query for all company product / service categories
    """
    connection field :list_company_categories, node_type: :category do
      arg(:company_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&StoreResolver.list_company_categories/2)
    end

    @desc """
      query all tags of a company
    """
    connection field :company_tags, node_type: :tag do
      arg(:company_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&StoreResolver.list_company_tags/2)
    end
  end
end