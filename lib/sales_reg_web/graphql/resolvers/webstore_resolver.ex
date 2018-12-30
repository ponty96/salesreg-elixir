defmodule SalesRegWeb.GraphQL.Resolvers.WebStoreResolver do
  use SalesRegWeb, :context

  def home_page_query(params, resolution) do
    company = resolution.context.company

    home_data = %{
      categories: Store.home_categories(company.id),
      featured_products: Store.load_featured_products(company.id),
      featured_services: Store.load_featured_services(company.id),
      company: company
    }

    {:ok, home_data}
  end

  def product_page_query(%{id: id}, resolution) do
    company = resolution.context.company
    %{product_group: product_group} = Store.get_product(id, preload: [:product_group])

    page_data = %{
      product_group: product_group,
      company: company,
      related_products: []
    }

    {:ok, page_data}
  end

  def service_page_query(%{id: id}, resolution) do
    company = resolution.context.company
    service = Store.get_service(id)

    page_data = %{
      service: service,
      company: company,
      related_services: []
    }

    {:ok, page_data}
  end

  def category_page_query(%{id: id}, resolution) do
  end
end
