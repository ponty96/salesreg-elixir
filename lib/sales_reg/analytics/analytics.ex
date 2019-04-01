defmodule SalesReg.Analytics do
  @moduledoc """
    Analytics module
  """
  use SalesRegWeb, :context

  def dashboard_info(:expense, start_date, end_date, group_by, company_id) do
    query = expenses_within_range(start_date, end_date, company_id)

    total_expense =
      query
      |> Repo.aggregate(:sum, :total_amount)
      |> to_float()

    top_expenses =
      Repo.all(
        from(e in query,
          select: %{
            total_in_group: sum(e.total_amount),
            grouped_by: min(e.date),
            title: max(e.title)
          },
          group_by: [fragment("date_trunc(?, ?)", ^group_by, e.date)],
          order_by: [desc: sum(e.total_amount)]
        )
      )

    top_expenses = top_expenses |> convert_decimal_items_to_float(:total_in_group)
    {:ok, %{total_expense: total_expense, top_expenses: top_expenses, group_by: group_by}}
  end

  defp expenses_within_range(start_date, end_date, company_id) do
    from(e in Expense,
      where: e.date <= ^end_date and e.date > ^start_date,
      where: e.company_id == ^company_id
    )
  end

  defp convert_decimal_items_to_float(items, field) do
    Enum.map(items, fn item ->
      converted_field =
        item
        |> Map.get(field)
        |> to_float()

      item |> Map.put(field, converted_field)
    end)
  end

  defp to_float(nil), do: 0.0
  defp to_float(decimal), do: Decimal.to_float(decimal)
end
