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
    upsert purchase order
    """
    field :upsert_purchase_order, :mutation_response do
      arg(:purchase, non_null(:purchase_input))
      arg(:purchase_id, :uuid)

      resolve(&OrderResolver.upsert_purchase/2)
    end

    ### Sale order mutations
    @desc """
    upsert a sale order
    """
    field :upsert_sale_order, :mutation_response do
      arg(:sale, non_null(:sale_input))
      arg(:sale_id, :uuid)

      resolve(&OrderResolver.upsert_sale/2)
    end

    @desc """
    update an order's status
    """
    field :update_order_status, :mutation_response do
      arg(:status, non_null(:order_status))
      arg(:id, :uuid)
      arg(:order_type, :string)

      resolve(&OrderResolver.update_order_status/2)
    end
  end

  ### QUERIES
  object :order_queries do
    ### Purchase order queries

    @desc """
      query for all purchases of a company
    """
    field :list_company_purchases, list_of(:purchase) do
      arg(:company_id, non_null(:uuid))

      resolve(&OrderResolver.list_company_purchases/2)
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
