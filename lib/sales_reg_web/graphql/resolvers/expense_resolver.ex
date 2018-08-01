defmodule SalesRegWeb.GraphQL.Resolvers.ExpenseResolver do
  use SalesRegWeb, :context

  def upsert_expense(%{expense: params, expense_id: id}, _res) do
    Business.get_expense(id)
    |> Business.update_expense(params)
  end

  def upsert_expense(%{expense: params}, _res) do
    Business.add_expense(params)
  end

  def list_company_expenses(%{company_id: id}, _res) do
    Business.list_company_expenses(id)
  end
end
