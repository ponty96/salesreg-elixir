defmodule SalesRegWeb.GraphQL.Resolvers.CustomerResolver do
  use SalesRegWeb, :context

  @phone_types ["home", "work", "mobile"]

  def upsert_customer(%{customer: %{phone: phone} = params, customer_id: id}, _res) do
    update_params =
      params
      |> add_phone_type(phone)

    Business.get_customer(id)
    |> Business.update_customer(update_params)
  end

  def upsert_customer(%{customer: %{phone: phone} = params}, _res) do
    params
    |> add_phone_type(phone)
    |> Business.add_customer()
  end

  def list_company_customers(%{company_id: company_id}, _res) do
    Business.list_company_customers(company_id)
  end

  def delete_customer(%{customer_id: customer_id}, _res) do
    Business.get_customer(customer_id)
    |> Business.delete_customer()
  end

  defp add_phone_type(params, phone) do
    %{params | phone: randomize_type(phone)}
  end

  defp randomize_type(map) do
    add_type = Map.put_new(map, :type, Enum.random(@phone_types))

    add_type
  end
end
