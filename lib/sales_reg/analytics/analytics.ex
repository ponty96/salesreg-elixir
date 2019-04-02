defmodule SalesReg.Analytics do
  @moduledoc """
    Analytics module
  """
  use SalesRegWeb, :context

  def dashboard_info(:expense, start_date, end_date, group_by, company_id) do
    query = schemas_within_range(Expense, start_date, end_date, company_id)

    total_expense =
      query
      |> Repo.aggregate(:sum, :total_amount)
      |> to_float()

    top_expenses =
      Repo.all(
        from(e in query,
          select: merge(map(e, ^[:title]), %{total_in_group: sum(e.total_amount)}),
          group_by: e.title,
          order_by: [desc: sum(e.total_amount)],
          limit: 5
        )
      )

    data_points =
      Repo.all(
        from(e in query,
          select: %{
            total: sum(e.total_amount),
            date: min(e.date)
          },
          group_by: [fragment("date_trunc(?, ?)", ^group_by, e.date)],
          order_by: [desc: sum(e.total_amount)]
        )
      )

    top_expenses = top_expenses |> convert_decimal_items_to_float(:total_in_group)

    {:ok,
     %{
       total_expense: total_expense,
       top_expenses: top_expenses,
       group_by: group_by,
       data_points: data_points
     }}
  end

  def dashboard_info(:order, start_date, end_date, group_by, company_id) do
    query = schemas_within_range(Sale, start_date, end_date, company_id)

    order_statuses =
      Repo.all(
        from(s in query,
          select: %{
            status: s.status,
            count: count(s.status)
          },
          group_by: s.status
        )
      )

    data_points =
      Repo.all(
        from(e in query,
          select: %{
            total: count(e.id),
            date: min(e.date)
          },
          group_by: [fragment("date_trunc(?, ?)", ^group_by, e.date)],
          order_by: [desc: count(e.id)]
        )
      )

    {:ok,
     %{
       order_statuses: order_statuses,
       group_by: group_by,
       data_points: data_points
     }}
  end

  defp schemas_within_range(schema, start_date, end_date, company_id) do
    from(sch in schema,
      where: sch.date <= ^end_date and sch.date > ^start_date,
      where: sch.company_id == ^company_id
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
