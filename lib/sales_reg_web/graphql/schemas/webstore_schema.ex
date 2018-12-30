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
    field :home_page_query, :home_data do
      resolve(&WebStoreResolver.home_page_query/2)
    end

    field :product_page_query, :product_page do
      arg(:id, :uuid)
      resolve(&WebStoreResolver.product_page_query/2)
    end

    field :service_page_query, :service_page do
      arg(:id, :uuid)
      resolve(&WebStoreResolver.service_page_query/2)
    end

    field :category_page_query, :category_page do
      arg(:id, :uuid)
      resolve(&WebStoreResolver.category_page_query/2)
    end
  end
end
