defmodule SalesRegWeb.GraphQL.Schemas.WebStoreSchema do
  @moduledoc """
    GraphQL Schemas for Company
  """
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :classic
  alias SalesRegWeb.GraphQL.Resolvers.WebStoreResolver
  alias SalesRegWeb.GraphQL.Resolvers.StoreResolver

  # WEBSTORE HOME PAGE
  object :web_store_queries do
    field :store_company, :company do
      resolve(&WebStoreResolver.company_details/2)
    end

    field :home_page_query, :home_data do
      resolve(&WebStoreResolver.home_page_query/2)
    end

    field :product_page_query, :product_group do
      arg(:slug, :string)
      resolve(&WebStoreResolver.product_page_query/2)
    end

    field :category_page_query, :category_page do
      arg(:slug, non_null(:string))
      arg(:product_page, :string)

      resolve(&WebStoreResolver.category_page_query/2)
    end

    field :store_page_query, :store_page do
      arg(:product_page, :string)

      resolve(&WebStoreResolver.store_page_query/2)
    end

    field :sale_page_query, :sale do
      arg(:sale_id, :uuid)

      resolve(&WebStoreResolver.sale_page_query/2)
    end

    field :invoice_page_query, :invoice do
      arg(:invoice_id, :uuid)

      resolve(&WebStoreResolver.invoice_page_query/2)
    end

    field :receipt_page_query, :receipt do
      arg(:receipt_id, :uuid)

      resolve(&WebStoreResolver.receipt_page_query/2)
    end

    field :get_product, :product do
      arg(:id, :uuid)

      resolve(&StoreResolver.get_product/2)
    end

    @desc """
      query for all company product categories
    """
    connection field(:categories_page_query, node_type: :category) do
      arg(:query, :string)

      resolve(&WebStoreResolver.categories_page_query/2)
    end
  end

  object :web_store_mutations do
    @desc """
    mutation for customer to create sales order
    """
    field :webstore_create_sale, :mutation_response do
      arg(:sale, non_null(:webstore_create_sale_input))

      resolve(&WebStoreResolver.create_sale_order/2)
    end
  end
end
