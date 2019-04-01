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
      arg(:start_date, :date)
      arg(:end_date, :date)

      middleware(Authorize)
      middleware(Policy)
      resolve(&AnalyticsResolver.expense_dashboard_info/2)
    end
  end
end
