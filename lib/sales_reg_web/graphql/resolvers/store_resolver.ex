defmodule SalesRegWeb.GraphQL.Resolvers.StoreResolver do
  use SalesRegWeb, :context

  def add_product(%{product: params}, _res) do
    Store.add_product(params)
  end

  def update_product(%{product: params, product_id: id}, _res) do
    Store.get_product(id)
    |> Store.update_product(params)
  end

  def list_company_products(%{company_id: company_id}, _res) do
    Store.list_company_products(company_id)
  end

  def add_service(%{service: params}, _res) do
    Store.add_service(params)
  end

  def update_service(%{service: params, service_id: id}, _res) do
    Store.get_service(id)
    |> Store.update_service(params)
  end

  def list_company_services(%{company_id: company_id}, _res) do
    Store.list_company_services(company_id)
  end
end
