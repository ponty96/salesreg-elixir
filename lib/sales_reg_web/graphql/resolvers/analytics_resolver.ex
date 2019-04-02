defmodule SalesRegWeb.GraphQL.Resolvers.AnalyticsResolver do
  @moduledoc """
  Analytics Resolver
  """
  use SalesRegWeb, :context

  def expense_dashboard_info(
        %{query: %{start_date: start_date, end_date: end_date, group_by: group_by}} = _params,
        res
      ) do
    Analytics.dashboard_info(:expense, start_date, end_date, group_by, res.context.company_id)
  end

  def order_dashboard_info(
        %{query: %{start_date: start_date, end_date: end_date, group_by: group_by}} = _params,
        res
      ) do
    Analytics.dashboard_info(:order, start_date, end_date, group_by, res.context.company_id)
  end

  def income_dashboard_info(
        %{query: %{start_date: start_date, end_date: end_date, group_by: group_by}} = _params,
        res
      ) do
    Analytics.dashboard_info(:income, start_date, end_date, group_by, res.context.company_id)
  end
end
