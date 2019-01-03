defmodule SalesRegWeb.GraphQL.Schemas.WebStoreSchema do
  @moduledoc """
    GraphQL Schemas for Company
  """
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :classic
  alias SalesRegWeb.GraphQL.Resolvers.WebStoreResolver
  alias SalesRegWeb.GraphQL.MiddleWares.Authorize

  # WEBSTORE HOME PAGE
  object :web_store_queries do
    field :store_company, :company do
      resolve(&WebStoreResolver.company_details/2)
    end

    field :home_page_query, :home_data do
      resolve(&WebStoreResolver.home_page_query/2)
    end

    field :product_page_query, :product_group do
      arg(:id, :uuid)
      resolve(&WebStoreResolver.product_page_query/2)
    end

    field :service_page_query, :service do
      arg(:id, :uuid)
      resolve(&WebStoreResolver.service_page_query/2)
    end

    field :category_page_query, :category_page do
      arg(:id, non_null(:uuid))
      arg(:service_page, :string)
      arg(:product_page, :string)

      resolve(&WebStoreResolver.category_page_query/2)
    end

    field :store_page_query, :store_page do
      arg(:service_page, :string)
      arg(:product_page, :string)

      resolve(&WebStoreResolver.store_page_query/2)
    end

    @desc """
      query for all company product / service categories
    """
    connection field(:categories_page_query, node_type: :category) do
      arg(:query, :string)

      resolve(&WebStoreResolver.categories_page_query/2)
    end
  end
end
