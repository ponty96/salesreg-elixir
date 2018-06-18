defmodule SalesRegWeb.GraphQL.Resolvers.CustomerResolver do
  use SalesRegWeb, :context

  @phone_types ["home", "work", "mobile"]

  def add_customer(%{customer: %{phones: phones} = params}, _res) do
    params
    |> add_phones_type(phones)
    |> Business.add_customer()
  end

  def update_customer(%{customer: %{phones: phones} = params, customer_id: customer_id}, _res) do
    update_params =
      params
      |> add_phones_type(phones)

    Business.get_customer(customer_id)
    |> Business.update_customer(update_params)
  end

  def list_company_customers(%{company_id: company_id}, _res) do
    Business.list_company_customers(company_id)
  end

  def delete_customer(%{customer_id: customer_id}, _res) do
    Business.get_customer(customer_id)
    |> Business.delete_customer()
  end

  defp add_phones_type(params, phones) do
    phones =
      phones
      |> Enum.map(fn map ->
        randomize_type(map)
      end)

    %{params | phones: phones}
  end

  defp randomize_type(map) do
    add_type = Map.put_new(map, :type, Enum.random(@phone_types))

    add_type
  end
end
