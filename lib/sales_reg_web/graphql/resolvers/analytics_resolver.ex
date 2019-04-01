defmodule SalesRegWeb.GraphQL.Resolvers.AnalyticsResolver do
  @moduledoc """
  Analytics Resolver
  """
  use SalesRegWeb, :context

  def expense_dashboard_info(%{start_date: start_date, end_date: end_date} = _params, res) do
    Analytics.dashboard_info(:expense, start_date, end_date, res.context.company_id)
  end
end
