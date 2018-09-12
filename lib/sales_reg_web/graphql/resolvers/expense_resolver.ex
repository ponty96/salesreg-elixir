defmodule SalesRegWeb.GraphQL.Resolvers.ExpenseResolver do
  use SalesRegWeb, :context

  def upsert_expense(%{expense: params, expense_id: id}, _res) do
    new_params = put_items_amount(params)
    Business.get_expense(id)
    |> Business.update_expense(new_params)
  end

  def upsert_expense(%{expense: params}, _res) do
    new_params = put_items_amount(params)
    Business.add_expense(new_params)
  end

  def list_company_expenses(%{company_id: id}, _res) do
    Business.list_company_expenses(id)
  end

  defp put_items_amount(params) do
    total_amount = 
      params.expense_items
      |> calc_expense_amount(0)

    Map.put_new(params, :items_amount, total_amount)
  end

  defp calc_expense_amount([], acc), do: acc
  
  defp calc_expense_amount([h | t], acc) do
    calc_expense_amount(t, acc + String.to_float(h.amount))
  end
end
