defmodule SalesRegWeb.GraphQL.Resolvers.WebStoreResolver do
  use SalesRegWeb, :context

  def company_details(_params, resolution) do
    company = resolution.context.company
    {:ok, company}
  end

  def home_page_query(params, resolution) do
    company = resolution.context.company

    home_data = %{
      categories: Store.home_categories(company.id),
      featured_products: Store.load_featured_products(company.id),
      company: company
    }

    {:ok, home_data}
  end

  def product_page_query(%{id: id}, _resolution) do
    %{product_group: product_group} = Store.get_product(id, preload: [:product_group])

    {:ok, product_group}
  end

  def category_page_query(%{id: id, product_page: p_page}, _resolution) do
    {%{entries: products}, product_page} =
      Store.category_products(id, p_page) |> Map.split([:entries])

    {:ok,
     %{
       category: Store.get_category(id),
       products: products,
       product_page: product_page
     }}
  end

  def categories_page_query(%{query: query} = args, resolution) do
    company = resolution.context.company
    Store.search_company_categorys([company_id: company.id], query, :title, pagination_args(args))
  end

  def store_page_query(%{product_page: p_page}, resolution) do
    company = resolution.context.company

    {%{entries: products}, product_page} =
      Store.filter_webstore_products(company.id, %{page: p_page}) |> Map.split([:entries])

    {:ok,
     %{
       products: products,
       product_page: product_page
     }}
  end

  defp pagination_args(args) do
    Map.take(args, [:first, :after, :last, :before])
  end
end
