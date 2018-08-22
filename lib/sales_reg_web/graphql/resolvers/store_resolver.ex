defmodule SalesRegWeb.GraphQL.Resolvers.StoreResolver do
  use SalesRegWeb, :context
  require SalesReg.Store

  def upsert_service(%{service: params, service_id: id}, _res) do
    Store.get_service(id)
    |> Store.update_service(params)
  end

  def upsert_service(%{service: params}, _res) do
    Store.add_service(params)
  end

  def list_company_services(%{company_id: company_id}, _res) do
    Store.list_company_services(company_id)
  end

  def search_services_by_name(%{query: query}, _res) do
    services = Store.search_schema_by_field(Service, query, :name)
    {:ok, services}
  end

  def upsert_product(%{product: params, product_id: id}, _res) do
    Store.get_product(id)
    |> Store.update_product(params)
  end

  def upsert_product(%{product: params}, _res) do
    Store.add_product(params)
  end

  def list_company_products(%{company_id: company_id}, _res) do
    Store.list_company_products(company_id)
  end
end
