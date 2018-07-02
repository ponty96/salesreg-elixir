defmodule SalesRegWeb.GraphQL.Schemas.OrderSchema do
  @moduledoc """
    GraphQL Schemas for Order
  """
  use Absinthe.Schema.Notation
  alias SalesRegWeb.GraphQL.Resolvers.OrderResolver

  ### MUTATIONS
  object :order_mutations do
    ### Purchase order mutations
    @desc """
    add a purchase order
    """
    field :add_purchase_order, :mutation_response do
      arg(:purchase, non_null(:purchase_input))

      resolve(&OrderResolver.add_purchase/2)
    end

    @desc """
    update a purchase order
    """
    field :update_purchase, :mutation_response do
      arg(:purchase, non_null(:purchase_input))
      arg(:purchase_id, non_null(:uuid))

      resolve(&OrderResolver.update_purchase/2)
    end

    @desc """
    cancel a particular purchase order
    """
    field :cancel_purchase_order, :mutation_response do
      arg(:purchase_id, non_null(:uuid))

      resolve(&OrderResolver.cancel_purchase_order/2)
    end

    ### Sale order mutations
    @desc """
    add a sale order
    """
    field :add_sale_order, :mutation_response do
      arg(:sale, non_null(:sale_input))

      resolve(&OrderResolver.add_sale/2)
    end

    @desc """
    update a sale order
    """
    field :update_sale, :mutation_response do
      arg(:sale, non_null(:sale_input))
      arg(:sale_id, non_null(:uuid))

      resolve(&OrderResolver.update_sale/2)
    end

    @desc """
    cancel a particular sale order
    """
    field :cancel_sale_order, :mutation_response do
      arg(:sale_id, non_null(:uuid))

      resolve(&OrderResolver.cancel_sale_order/2)
    end
  end

  ### QUERIES
  object :order_queries do
    ### Purchase order queries
    @desc """
      query for all purchases of a vendor
    """
    field :list_vendor_purchases, list_of(:purchase) do
      arg(:vendor_id, non_null(:uuid))

      resolve(&OrderResolver.list_vendor_purchases/2)
    end

    @desc """
      query for all purchases of a company
    """
    field :list_company_purchases, list_of(:purchase) do
      arg(:company_id, non_null(:uuid))

      resolve(&OrderResolver.list_company_purchases/2)
    end

    ### Sale order queries
    @desc """
      query for all sales of a customer
    """
    field :list_customer_sales, list_of(:sale) do
      arg(:customer_id, non_null(:uuid))

      resolve(&OrderResolver.list_customer_sales/2)
    end

    @desc """
      query for all sales of a company
    """
    field :list_company_sales, list_of(:sale) do
      arg(:company_id, non_null(:uuid))

      resolve(&OrderResolver.list_company_sales/2)
    end
  end
end
