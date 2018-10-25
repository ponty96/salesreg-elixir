defmodule SalesRegWeb.GraphQL.Resolvers.BusinessResolver do
  use SalesRegWeb, :context

  def register_company(%{user: user_id, company: company_params}, _resolution) do
    with {:ok, company} <- Business.create_company(user_id, company_params),
         {:ok, _} <- Business.send_registration_email(user_id, company) do
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

  def list_company_banks(%{company_id: id}, _res) do
    banks =
      Business.list_company_banks(id)
      |> elem(1)
      |> Enum.sort(&(&1.is_primary >= &2.is_primary))

    {:ok, banks}
  end

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

  defp calc_expense_amount([], 0), do: 0.0
  defp calc_expense_amount([], acc), do: Float.round(acc, 2)

  defp calc_expense_amount([h | t], acc) do
    calc_expense_amount(t, acc + h.amount)
  end
end
