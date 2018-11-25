defmodule SalesRegWeb.GraphQL.Resolvers.StoreResolver do
  use SalesRegWeb, :context
  require SalesReg.Context

  def upsert_service(%{service: params, service_id: id}, _res) do
    Store.update_service(id, params)
  end

  def upsert_service(%{service: params}, _res) do
    Store.add_service(params)
  end

  def list_company_services(%{company_id: company_id}, _res) do
    Store.list_company_services(company_id)
  end

  def search_services_by_name(%{query: query}, _res) do
    services = Context.search_schema_by_field(Service, query, :name)
    {:ok, services}
  end

  def delete_service(%{service_id: service_id}, _res) do
    service = Store.get_service(service_id)
    Store.delete_service(service)
  end

  def upsert_product(%{product: params, product_id: id}, _res) do
    Store.update_product(id, params)
  end

  def upsert_product(%{product: params}, _res) do
    Store.add_product(params)
  end

  def list_company_products(%{company_id: company_id}, _res) do
    Store.list_company_products(company_id)
  end

  def search_products_by_name(%{query: query}, _res) do
    products = Context.search_schema_by_field(Product, query, :name)
    {:ok, products}
  end

  def delete_product(%{product_id: product_id}, _res) do
    product = Store.get_product(product_id)
    Store.delete_product(product)
  end

  def list_featured_items(%{company_id: company_id}, _res) do
    Store.list_featured_items(company_id)
  end

  def list_top_rated_items(%{company_id: company_id}, _res) do
    Store.list_top_rated_items(company_id)
  end

  # category
  def upsert_category(%{category: params, category_id: id}, _res) do
    Store.get_category(id)
    |> Store.update_category(params)
  end

  def upsert_category(%{category: params}, _res) do
    Store.add_category(params)
  end

  def list_company_categories(%{company_id: company_id}, _res) do
    ## TODO - change context to use plural form
    Store.list_company_categorys(company_id)
  end

end
