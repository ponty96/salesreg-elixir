defmodule SalesRegWeb.GraphQL.Schemas.StoreSchema do
  @moduledoc """
    GraphQL Schemas for Store
  """
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :classic
  alias SalesRegWeb.GraphQL.Resolvers.StoreResolver
  alias SalesRegWeb.GraphQL.MiddleWares.Authorize

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
      arg(:params, non_null(:product_group_input))

      middleware(Authorize)
      resolve(&StoreResolver.create_product/2)
    end

    @desc """
      Update Product Group Options
    """
    field :update_product_group_options, :mutation_response do
      arg(:id, non_null(:uuid))
      arg(:options, non_null(list_of(:uuid)))

      middleware(Authorize)
      resolve(&StoreResolver.update_product_group_options/2)
    end

    @desc """
      Update Product
    """
    field :update_product, :mutation_response do
      arg(:product, non_null(:product_input))
      arg(:product_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&StoreResolver.update_product/2)
    end

    @desc """
    upsert a category in a company's store
    """
    field :upsert_category, :mutation_response do
      arg(:category, non_null(:category_input))
      arg(:category_id, :uuid)

      middleware(Authorize)
      resolve(&StoreResolver.upsert_category/2)
    end

    @desc """
    upsert an option in a company's store
    """
    field :upsert_option, :mutation_response do
      arg(:option, non_null(:option_input))
      arg(:option_id, :uuid)

      middleware(Authorize)
      resolve(&StoreResolver.upsert_option/2)
    end

    @desc """
      mutation to delete product
    """
    field :delete_product, :mutation_response do
      arg(:product_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&StoreResolver.delete_product/2)
    end

    @desc """
      mutation to delete category
    """
    field :delete_category, :mutation_response do
      arg(:category_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&StoreResolver.delete_category/2)
    end

    @desc """
      mutation to delete option
    """
    field :delete_option, :mutation_response do
      arg(:option_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&StoreResolver.delete_option/2)
    end

    @desc """
      mutation to restock products
    """
    field :restock_products, :mutation_response do
      arg(:items, list_of(:restock_item_input))

      middleware(Authorize)
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
      resolve(&StoreResolver.search_company_products/2)
    end

    @desc """
      query for all company product / service categories
    """
    connection field(:list_company_categories, node_type: :category) do
      arg(:company_id, non_null(:uuid))
      arg(:query, non_null(:string))

      middleware(Authorize)
      resolve(&StoreResolver.search_company_categories/2)
    end

    @desc """
      query for all company options
    """
    connection field(:list_company_options, node_type: :option) do
      arg(:company_id, non_null(:uuid))
      arg(:query, non_null(:string))

      middleware(Authorize)
      resolve(&StoreResolver.search_company_options/2)
    end

    @desc """
     search for product groups by title
    """
    field :search_product_groups_by_title, list_of(:product_group) do
      arg(:query, non_null(:string))
      arg(:company_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&StoreResolver.search_product_groups_by_title/2)
    end

    @desc """
     search for options by name
    """
    field :search_options_by_name, list_of(:option) do
      arg(:query, non_null(:string))
      arg(:company_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&StoreResolver.search_options_by_name/2)
    end

    @desc """
     search for categories by title
    """
    field :search_categories_by_title, list_of(:category) do
      arg(:query, non_null(:string))
      arg(:company_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&StoreResolver.search_categories_by_title/2)
    end

    @desc """
     search for products by name
    """
    field :search_products_by_name, list_of(:product) do
      arg(:query, non_null(:string))
      arg(:company_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&StoreResolver.search_products_by_name/2)
    end
  end
end
