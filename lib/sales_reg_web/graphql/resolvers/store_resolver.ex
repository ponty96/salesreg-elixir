defmodule SalesRegWeb.GraphQL.Resolvers.StoreResolver do
  use SalesRegWeb, :context
  require SalesReg.Context

  def upsert_service(%{service: params, service_id: id}, _res) do
    Store.get_service(id)
    |> Store.update_service(params)
  end

  def upsert_service(%{service: params}, _res) do
    Store.add_service(params)
  end

  def list_company_services(%{company_id: company_id} = args, _res) do
    {:ok, services} = Store.list_company_services(company_id)
    
    services
    |> Absinthe.Relay.Connection.from_list(pagination_args(args))
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

  def list_company_products(%{company_id: company_id} = args, _res) do
    {:ok, products} = Store.list_company_products(company_id)
  
    products
    |> Absinthe.Relay.Connection.from_list(pagination_args(args))
  end

  def search_products_services_by_name(%{query: query}, _res) do
    products_and_services = Store.load_prod_and_serv(query)
 
    {:ok, products_and_services}
  end

  def delete_product(%{product_id: product_id}, _res) do
    product = Store.get_product(product_id)
    Store.delete_product(product)
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

  def create_product(%{params: params}, _res) do
    Store.create_product(params)
  end

  def update_product(%{product: params, product_id: id}, _res) do
    Store.get_product(id)
    |> Store.update_product(params)
  end

  def update_product_group_options(%{id: id, options: options} = params, _res) do
    Store.update_product_group_options(params)
  end
end
