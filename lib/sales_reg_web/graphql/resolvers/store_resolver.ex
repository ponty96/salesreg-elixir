defmodule SalesRegWeb.GraphQL.Resolvers.StoreResolver do
  use SalesRegWeb, :context
  require SalesReg.Context

  def upsert_service(%{service: params, service_id: id}, _res) do
    Store.update_service(id, params)
  end

  def upsert_service(%{service: params}, _res) do
    Store.create_service(params)
  end

  def list_company_services(%{company_id: company_id}, _res) do
    Store.list_company_services(company_id)
  end

  def search_services_by_name(%{query: query}, _res) do
    services = Context.search_schema_by_field(Service, query, :name)
    {:ok, services}
  end

  def upsert_product(%{product: params, product_id: id}, _res) do
    Store.update_product(id, params)
  end

  def upsert_product(%{product: params}, _res) do
    Store.create_product(params)
  end

  def list_company_products(%{company_id: company_id}, _res) do
    Store.list_company_products(company_id)
  end

  def search_products_by_name(%{query: query}, _res) do
    products = Context.search_schema_by_field(Product, query, :name)
    {:ok, products}
  end
end
