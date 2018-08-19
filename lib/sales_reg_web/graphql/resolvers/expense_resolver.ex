defmodule SalesRegWeb.GraphQL.Resolvers.ExpenseResolver do
  use SalesRegWeb, :context

  def upsert_expense(%{expense: params, expense_id: id}, _res) do
    new_params = new_expense_params(params)
    
    Business.get_expense(id)
    |> Business.update_expense(new_params)
  end

  def upsert_expense(%{expense: params}, _res) do
    new_params = new_expense_params(params)
    Business.add_expense(new_params)
  end

  def list_company_expenses(%{company_id: id}, _res) do
    Business.list_company_expenses(id)
  end

  # Private functions
  defp new_expense_params(params) do
    amount = calc_expense_amount(params.expense_items, 0)
    items = stringify_keys(params.expense_items)
    new_params = Map.put_new(params, :total_amount, amount)

    %{new_params | expense_items: items}
  end

  defp calc_expense_amount([], acc), do: Float.to_string(acc)
  defp calc_expense_amount([h | t], acc) do
    calc_expense_amount(t, acc + h.amount)
  end
  
  defp stringify_keys(items) do
    Enum.map(items, fn(item) ->
      value = Float.to_string(item.amount)
      %{item | amount: value}
    end)
  end
end
