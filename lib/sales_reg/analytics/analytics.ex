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

    data_points = expense_data_points(query, group_by)

    top_expenses = get_top_expenses(query)

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

    order_statuses = get_order_statuses(query)

    data_points = order_data_points(query, group_by)

    {:ok,
     %{
       order_statuses: order_statuses,
       group_by: group_by,
       data_points: data_points
     }}
  end

  def dashboard_info(:income, start_date, end_date, group_by, company_id) do
    incomes_in_range_query =
      start_date
      |> income_within_range(end_date, company_id)

    total_income =
      incomes_in_range_query
      |> Repo.aggregate(:sum, :amount_paid)
      |> to_float()

    items_query = income_items_query(start_date, end_date, company_id)

    amount_due = income_amount_due(items_query)

    total_products = Repo.aggregate(items_query, :sum, :quantity)

    top_products = income_top_products(items_query)

    data_points = income_data_points(incomes_in_range_query, group_by)

    {:ok,
     %{
       total_income: total_income,
       total_products: total_products,
       top_products: top_products,
       amount_due: amount_due,
       data_points: data_points
     }}
  end

  defp expense_data_points(query, group_by) do
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
  end

  defp get_top_expenses(query) do
    top_expenses =
      Repo.all(
        from(e in query,
          select: merge(map(e, ^[:title]), %{total_in_group: sum(e.total_amount)}),
          group_by: e.title,
          order_by: [desc: sum(e.total_amount)],
          limit: 5
        )
      )

    top_expenses |> convert_decimal_items_to_float(:total_in_group)
  end

  defp get_order_statuses(query) do
    Repo.all(
      from(s in query,
        select: %{
          status: s.status,
          count: count(s.status)
        },
        group_by: s.status
      )
    )
  end

  defp order_data_points(query, group_by) do
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
  end

  defp income_top_products(items_query) do
    query =
      Repo.all(
        from(i in items_query,
          select: %{product_id: i.product_id, title: "", amount: sum(i.quantity * i.unit_price)},
          group_by: i.product_id,
          order_by: [desc: sum(i.quantity * i.unit_price)]
        )
      )

    query
    |> Enum.map(fn product ->
      title = Store.get_product_name_by_id(product.product_id)
      %{product | title: title}
    end)
  end

  defp income_amount_due(items_query) do
    amount_due_query =
      from(i in items_query,
        select: sum(i.quantity * i.unit_price)
      )

    amount_due_query
    |> Repo.all()
    |> Enum.at(0)
  end

  defp income_data_points(incomes_in_range_query, group_by) do
    Repo.all(
      from(inc in incomes_in_range_query,
        select: %{
          total: sum(inc.amount_paid),
          date: min(inc.time_paid)
        },
        group_by: [fragment("date_trunc(?, ?)", ^group_by, inc.time_paid)],
        order_by: [desc: count(inc.amount_paid)]
      )
    )
  end

  defp income_items_query(start_date, end_date, company_id) do
    from(i in Item,
      join: s in Sale,
      on: s.id == i.sale_id and s.company_id == ^company_id,
      where: s.date <= ^end_date and s.date > ^start_date
    )
  end

  defp income_within_range(start_date, end_date, company_id) do
    from(sch in Receipt,
      where: sch.time_paid <= ^end_date and sch.time_paid > ^start_date,
      where: sch.company_id == ^company_id
    )
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
