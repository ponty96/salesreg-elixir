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
  end
end
