defmodule SalesRegWeb.GraphQL.Schemas.OrderSchema do
  @moduledoc """
    GraphQL Schemas for Order
  """
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :classic
  alias SalesRegWeb.GraphQL.Resolvers.OrderResolver
  alias SalesRegWeb.GraphQL.MiddleWares.Authorize

  ### MUTATIONS
  object :order_mutations do
    ### Sale order mutations
    @desc """
    upsert a sale order
    """
    field :upsert_sale_order, :mutation_response do
      arg(:sale, non_null(:sale_input))
      arg(:sale_id, :uuid)

      middleware(Authorize)
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

      middleware(Authorize)
      resolve(&OrderResolver.update_order_status/2)
    end

    @desc """
      update invoice due date
    """
    field :update_invoice, :mutation_response do
      arg(:invoice, non_null(:invoice_input))
      arg(:id, non_null(:uuid))

      middleware(Authorize)
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

    ### Receipt mutations
    @desc """
    upsert a receipt
    """
    field :upsert_receipt, :mutation_response do
      arg(:receipt, non_null(:receipt_input))

      resolve(&OrderResolver.upsert_receipt/2)
    end

    @desc """
      create a receipt when payment is by cash
    """
    field :create_receipt, :mutation_response do
      arg(:invoice_id, non_null(:uuid))
      arg(:amount_paid, non_null(:string))

      resolve(&OrderResolver.create_receipt/2)
    end

    @desc """
      mutation to delete receipt
    """
    field :delete_receipt, :mutation_response do
      arg(:receipt_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&OrderResolver.delete_receipt/2)
    end
  end

  ### QUERIES
  object :order_queries do
    @desc """
      query for all sales of a company
    """
    connection field(:list_company_sales, node_type: :sale) do
      arg(:company_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&OrderResolver.list_company_sales/2)
    end
  end
end
