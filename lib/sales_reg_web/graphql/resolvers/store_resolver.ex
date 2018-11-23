defmodule SalesRegWeb.GraphQL.Resolvers.StoreResolver do
  use SalesRegWeb, :context
  require SalesReg.Context

  def upsert_service(%{service: params, service_id: id}, _res) do
    Store.update_service(id, params)
  end

  def upsert_service(%{service: params}, _res) do
    Store.add_service(params)
  end

  def list_company_services(%{company_id: company_id} = args, _res) do
    {:ok, services} = Store.list_company_services(company_id)

    services
    |> Absinthe.Relay.Connection.from_list(pagination_args(args))
  end

  def search_services_by_name(%{query: query}, _res) do
    services = Context.search_schema_by_field(Service, query, :name)
    {:ok, services}
  end

  def upsert_product(%{product: params, product_id: id}, _res) do
    Store.update_product(id, params)
  end

  def upsert_product(%{product: params}, _res) do
    Store.add_product(params)
  end

  def list_company_products(%{company_id: company_id} = args, _res) do
    {:ok, products} = Store.list_company_products(company_id)
  
    products
    |> Absinthe.Relay.Connection.from_list(pagination_args(args))
  end

  def search_products_by_name(%{query: query}, _res) do
    products = Context.search_schema_by_field(Product, query, :name)
    {:ok, products}
  end

  # category
  def upsert_category(%{category: params, category_id: id}, _res) do
    Store.get_category(id)
    |> Store.update_category(params)
  end

  def upsert_category(%{category: params}, _res) do
    Store.add_category(params)
  end

  def list_company_categories(%{company_id: company_id} = args, _res) do
    {:ok, categories} = Store.list_company_categorys(company_id)

    categories
    |> Absinthe.Relay.Connection.from_list(pagination_args(args))
  end

  # tag
  def list_company_tags(%{company_id: id} = args, _res) do
    {:ok, tags} = Business.list_company_tags(id)

    tags
    |> Absinthe.Relay.Connection.from_list(pagination_args(args))
  end

  defp pagination_args(args) do
    Map.take(args, [:first, :after, :last, :before])
  end
end
