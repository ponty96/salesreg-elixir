defmodule SalesRegWeb.GraphQL.Resolvers.StoreResolver do
  use SalesRegWeb, :context
  require SalesReg.Context

  def create_product(%{params: params}, _res) do
    Store.create_product(params)
  end

  def update_product(%{product: params, product_id: id}, _res) do
    Store.get_product(id)
    |> Store.update_product(params)
  end

  def update_product_group_options(params, _res) do
    Store.update_product_group_options(params)
  end

  def get_product(%{id: id}, _res) do
    {:ok, Store.get_product(id)}
  end

  # category
  def upsert_category(%{category: params, category_id: id}, _res) do
    Store.get_category(id)
    |> Store.update_category(params)
  end

  def upsert_category(%{category: params}, _res) do
    Store.add_category(params)
  end

  # option
  def upsert_option(%{option: params, option_id: id}, _res) do
    Store.get_option(id)
    |> Store.update_option(params)
  end

  def upsert_option(%{option: params}, _res) do
    Store.add_option(params)
  end

  def delete_product(%{product_id: product_id}, _res) do
    product = Store.get_product(product_id)
    Store.delete_product(product)
  end

  def delete_category(%{category_id: category_id}, _res) do
    category = Store.get_category(category_id)
    Store.delete_category(category)
  end

  def delete_option(%{option_id: option_id}, _res) do
    option = Store.get_option(option_id)
    Store.delete_option(option)
  end

  def search_company_products(%{company_id: id, query: query} = args, _res) do
    Store.load_products(id, query, pagination_args(args))
  end

  def search_company_categories(%{company_id: id, query: query} = args, _res) do
    [company_id: id]
    |> Store.search_company_categorys(query, :title, pagination_args(args))
  end

  def search_company_options(%{company_id: id, query: query} = args, _res) do
    [company_id: id]
    |> Store.search_company_options(query, :name, pagination_args(args))
  end

  def search_product_groups_by_title(%{company_id: company_id, query: query}, _res) do
    {:ok, SalesReg.Context.search_schema_by_field(ProductGroup, {query, company_id}, :title)}
  end

  def search_options_by_name(%{company_id: company_id, query: query}, _res) do
    {:ok, SalesReg.Context.search_schema_by_field(Option, {query, company_id}, :name)}
  end

  def search_categories_by_title(%{company_id: company_id, query: query}, _res) do
    {:ok, SalesReg.Context.search_schema_by_field(Category, {query, company_id}, :title)}
  end

  def search_products_by_name(%{company_id: company_id, query: query}, _res) do
    {:ok, Store.load_products(company_id, query)}
  end

  def restock_products(%{items: items}, _res) do
    {:ok, Store.update_product_inventory(:increment, items)}
  end

  def list_related_products(%{product_id: product_id, company_id: company_id} = params, _res) do
    {:ok, Store.load_related_products(company_id, product_id, params.limit, params.offset)}
  end

  defp pagination_args(args) do
    Map.take(args, [:first, :after, :last, :before])
  end
end
