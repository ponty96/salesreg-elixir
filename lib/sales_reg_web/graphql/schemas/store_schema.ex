defmodule SalesRegWeb.GraphQL.Schemas.StoreSchema do
  @moduledoc """
    GraphQL Schemas for Store
  """
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :classic
  alias SalesRegWeb.GraphQL.MiddleWares.Authorize
  alias SalesRegWeb.GraphQL.MiddleWares.Policy
  alias SalesRegWeb.GraphQL.Resolvers.StoreResolver

  ### MUTATIONS
  object :store_mutations do
    # @desc """
    # upsert a product in a company's store
    # """
    # field :upsert_product, :mutation_response do
    #   deprecate
    #   arg(:product, non_null(:product_input))
    #   arg(:product_id, :uuid)

    #   middleware(Authorize)
    #   resolve(&StoreResolver.upsert_product/2)
    # end

    @desc """
      Create a product
    """
    field :create_product, :mutation_response do
      arg(:params, non_null(:product_input))

      middleware(Authorize)
      middleware(Policy)
      resolve(&StoreResolver.create_product/2)
    end

    @desc """
      Update Product
    """
    field :update_product, :mutation_response do
      arg(:product, non_null(:product_input))
      arg(:product_id, non_null(:uuid))

      middleware(Authorize)
      middleware(Policy)
      resolve(&StoreResolver.update_product/2)
    end

    @desc """
    upsert a category in a company's store
    """
    field :upsert_category, :mutation_response do
      arg(:category, non_null(:category_input))
      arg(:category_id, :uuid)

      middleware(Authorize)
      middleware(Policy)
      resolve(&StoreResolver.upsert_category/2)
    end

    @desc """
      mutation to delete product
    """
    field :delete_product, :mutation_response do
      arg(:product_id, non_null(:uuid))

      middleware(Authorize)
      middleware(Policy)
      resolve(&StoreResolver.delete_product/2)
    end

    @desc """
      mutation to delete category
    """
    field :delete_category, :mutation_response do
      arg(:category_id, non_null(:uuid))

      middleware(Authorize)
      middleware(Policy)
      resolve(&StoreResolver.delete_category/2)
    end

    @desc """
      mutation to restock products
    """
    field :restock_products, :mutation_response do
      arg(:items, list_of(:restock_item_input))

      middleware(Authorize)
      middleware(Policy)
      resolve(&StoreResolver.restock_products/2)
    end
  end

  ### QUERIES
  object :store_queries do
    @desc """
      query for all products in a company's store
    """
    connection field(:list_company_products, node_type: :product) do
      arg(:company_id, non_null(:uuid))
      arg(:query, non_null(:string))

      middleware(Authorize)
      middleware(Policy)
      resolve(&StoreResolver.search_company_products/2)
    end

    @desc """
      query for all company product categories
    """
    connection field(:list_company_categories, node_type: :category) do
      arg(:company_id, non_null(:uuid))
      arg(:query, non_null(:string))

      middleware(Authorize)
      middleware(Policy)
      resolve(&StoreResolver.search_company_categories/2)
    end

    @desc """
     search for categories by title
    """
    field :search_categories_by_title, list_of(:category) do
      arg(:query, non_null(:string))
      arg(:company_id, non_null(:uuid))

      middleware(Authorize)
      middleware(Policy)
      resolve(&StoreResolver.search_categories_by_title/2)
    end

    @desc """
     search for products by name
    """
    field :search_products_by_name, list_of(:product) do
      arg(:query, non_null(:string))
      arg(:company_id, non_null(:uuid))

      middleware(Authorize)
      middleware(Policy)
      resolve(&StoreResolver.search_products_by_name/2)
    end

    @desc """
      list related products
    """
    field :list_related_products, list_of(:product) do
      arg(:product_id, non_null(:uuid))
      arg(:company_id, non_null(:uuid))
      arg(:limit, non_null(:integer))
      arg(:offset, non_null(:integer))

      middleware(Authorize)
      middleware(Policy)
      resolve(&StoreResolver.list_related_products/2)
    end

    @desc """
      get product by id
    """
    field(:get_product_by_id, :product) do
      arg(:product_id, non_null(:uuid))

      middleware(Authorize)
      middleware(Policy)
      resolve(&StoreResolver.get_product_by_id/2)
    end
  end
end
