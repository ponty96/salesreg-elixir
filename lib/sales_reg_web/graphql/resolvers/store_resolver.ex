defmodule SalesRegWeb.GraphQL.Resolvers.StoreResolver do
  use SalesRegWeb, :context

  def add_product(%{product: params}, _res) do
    Store.create_product(params)
  end

  def update_product(%{product: params, product_id: id}, _res) do
    Store.update_product(id, params)
  end

  def list_company_products(%{company_id: company_id}, _res) do
    Store.list_company_products(company_id)
  end
end
