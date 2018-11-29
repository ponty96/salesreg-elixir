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

    @desc """
      delete a purchase order
    """
    field :delete_purchase_order, :mutation_response do
      arg(:purchase_id, non_null(:uuid))

      resolve(&OrderResolver.delete_purchase/2)
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
    delete a sale order
    """
    field :delete_sale_order, :mutation_response do
      arg(:sale_id, non_null(:uuid))

      resolve(&OrderResolver.delete_sale/2)
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

    @desc """
      update invoice due date
    """
    field :update_invoice, :mutation_response do
      arg(:invoice, non_null(:invoice_input))
      arg(:id, non_null(:uuid))

      resolve(&OrderResolver.update_invoice_due_date/2)
    end

    @desc """
      add product review
    """
    field :add_review, :mutation_response do
      arg(:review, non_null(:review_input))
      
      resolve(&OrderResolver.add_review/2)
    end

    @desc """
    add product star
    """
    field :add_star, :mutation_response do
      arg(:star, non_null(:star_input))

      resolve(&OrderResolver.add_star/2)
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
