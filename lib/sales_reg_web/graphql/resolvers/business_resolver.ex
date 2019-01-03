defmodule SalesRegWeb.GraphQL.Resolvers.BusinessResolver do
  use SalesRegWeb, :context

  def register_company(%{user: user_id, company: company_params}, _resolution) do
    with {:ok, company} <- Business.create_company(user_id, company_params) do
      {:ok, company}
    else
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_company(%{id: company_id, company: company_params}, _res) do
    {_status, result} = Business.update_company_details(company_id, company_params)

    case result do
      %Company{} -> {:ok, result}
      %Ecto.Changeset{} -> {:error, result}
    end
  end

  def upsert_bank(%{bank: params, bank_id: id}, _res) do
    Business.get_bank(id)
    |> Business.update_bank_details(params)
  end

  def upsert_bank(%{bank: params}, _res) do
    Business.create_bank(params)
  end

  def delete_bank(%{bank_id: bank_id}, _res) do
    Business.get_bank(bank_id)
    |> Business.delete_bank()
  end

  def list_company_banks(%{company_id: id} = args, _res) do
    {:ok, paginated_result} =
      [company_id: id]
      |> Business.paginated_list_company_banks(pagination_args(args))

    %{edges: edges} = paginated_result

    {:ok,
     %{
       paginated_result
       | edges:
           Enum.sort(
             edges,
             &(&1.node.is_primary >= &2.node.is_primary)
           )
     }}
  end

  def upsert_expense(%{expense: params, expense_id: id}, _res) do
    Business.get_expense(id)
    |> Business.update_expense_details(params)
  end

  def upsert_expense(%{expense: params}, _res) do
    Business.create_expense(params)
  end

  def company_expenses(%{company_id: id, query: query} = args, _res) do
    [company_id: id]
    |> Business.search_company_expenses(query, :title, pagination_args(args))
  end

  def delete_expense(%{expense_id: expense_id}, _res) do
    Business.get_expense(expense_id)
    |> Business.delete_expense()
  end

  defp pagination_args(args) do
    Map.take(args, [:first, :after, :last, :before])
  end
end
