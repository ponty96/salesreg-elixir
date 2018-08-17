defmodule SalesRegWeb.GraphQL.Resolvers.CustomerResolver do
  use SalesRegWeb, :context

  def upsert_customer(%{customer: params, customer_id: id}, _res) do
    Business.get_customer(id)
    |> Business.update_customer(params)
  end

  def upsert_customer(%{customer: params}, _res) do
    params
    |> Business.add_customer()
  end

  def list_company_customers(%{company_id: company_id}, _res) do
    Business.list_company_customers(company_id)
  end

  def delete_customer(%{customer_id: customer_id}, _res) do
    Business.get_customer(customer_id)
    |> Business.delete_customer()
  end
end
