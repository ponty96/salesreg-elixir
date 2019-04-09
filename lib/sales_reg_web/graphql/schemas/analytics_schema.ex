defmodule SalesRegWeb.GraphQL.Schemas.AnalyticsSchema do
  @moduledoc """
    GraphQL Schemas for Analytics
  """
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :classic
  alias SalesRegWeb.GraphQL.MiddleWares.Authorize
  alias SalesRegWeb.GraphQL.MiddleWares.Policy
  alias SalesRegWeb.GraphQL.Resolvers.AnalyticsResolver

  object :dashboard_infos do
    @desc """
      query for dashboard expense info
    """
    field :expense_dashboard_info, :expense_dashboard_data do
      arg(:query, :graph_query_input)

      middleware(Authorize)
      middleware(Policy)
      resolve(&AnalyticsResolver.expense_dashboard_info/2)
    end

    @desc """
      query for dashboard order info
    """
    field :order_dashboard_info, :order_dashboard_data do
      arg(:query, :graph_query_input)

      middleware(Authorize)
      middleware(Policy)
      resolve(&AnalyticsResolver.order_dashboard_info/2)
    end

    @desc """
      query for dashboard order info
    """
    field :income_dashboard_info, :income_dashboard_data do
      arg(:query, :graph_query_input)

      middleware(Authorize)
      middleware(Policy)
      resolve(&AnalyticsResolver.income_dashboard_info/2)
    end
  end
end
