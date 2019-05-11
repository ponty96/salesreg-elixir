defmodule SalesRegWeb.GraphQL.Schemas.OrderSchema do
  @moduledoc """
    GraphQL Schemas for Order
  """
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :classic
  alias SalesRegWeb.GraphQL.MiddleWares.Authorize
  alias SalesRegWeb.GraphQL.MiddleWares.Policy
  alias SalesRegWeb.GraphQL.Resolvers.OrderResolver

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
      middleware(Policy)
      resolve(&OrderResolver.upsert_sale/2)
    end

    @desc """
    delete a sale order
    """
    field :delete_sale_order, :mutation_response do
      arg(:sale_id, non_null(:uuid))

      middleware(Authorize)
      middleware(Policy)
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
      middleware(Policy)
      resolve(&OrderResolver.update_order_status/2)
    end

    @desc """
      update invoice due date
    """
    field :update_invoice, :mutation_response do
      arg(:invoice, non_null(:invoice_input))
      arg(:invoice_id, non_null(:uuid))

      middleware(Authorize)
      middleware(Policy)
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
      create a receipt when payment is by cash
    """
    field :create_receipt, :mutation_response do
      arg(:invoice_id, non_null(:uuid))
      arg(:amount_paid, non_null(:string))

      middleware(Authorize)
      middleware(Policy)
      resolve(&OrderResolver.create_receipt/2)
    end

    ### Delivery Charge mutations
    @desc """
      create delivery fee
    """
    field :create_delivery_fee, :mutation_response do
      arg(:delivery_fee, non_null(:delivery_fee_input))

      middleware(Authorize)
      middleware(Policy)
      resolve(&OrderResolver.create_delivery_fee/2)
    end

    @desc """
      delete a delivery fee
    """
    field :delete_delivery_fee, :mutation_response do
      arg(:delivery_fee_id, non_null(:uuid))

      middleware(Authorize)
      middleware(Policy)
      resolve(&OrderResolver.delete_delivery_fee/2)
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
      middleware(Policy)
      resolve(&OrderResolver.list_company_sales/2)
    end

    @desc """
      query for all invoices of a company
    """
    connection field(:list_company_invoices, node_type: :invoice) do
      arg(:company_id, non_null(:uuid))

      middleware(Authorize)
      middleware(Policy)
      resolve(&OrderResolver.list_company_invoices/2)
    end

    @desc """
      get invoice by id
    """
    field(:get_invoice_by_id, :invoice) do
      arg(:invoice_id, non_null(:uuid))

      middleware(Authorize)
      middleware(Policy)
      resolve(&OrderResolver.get_invoice_by_id/2)
    end

    @desc """
      get sale by id
    """
    field(:get_sale_by_id, :sale) do
      arg(:sale_id, non_null(:uuid))

      middleware(Authorize)
      middleware(Policy)
      resolve(&OrderResolver.get_sale_by_id/2)
    end

    @desc """
      query for all activities of a company contact
    """
    connection field(:list_contact_activities, node_type: :activity) do
      arg(:company_id, non_null(:uuid))
      arg(:contact_id, non_null(:uuid))

      middleware(Authorize)
      middleware(Policy)
      resolve(&OrderResolver.list_company_activities/2)
    end

    @desc """
      query for all delivery fees of a company
    """
    field :list_company_delivery_fees, list_of(:delivery_fee) do
      arg(:company_id, non_null(:uuid))

      middleware(Authorize)
      middleware(Policy)
      resolve(&OrderResolver.list_company_delivery_fees/2)
    end

    # @desc """
    # query if company has delivery_fee for nation wide delivery
    # """
    field :company_allows_nationwide_delivery, :nation_wide_delivery do
      arg(:company_id, non_null(:uuid))

      middleware(Authorize)
      middleware(Policy)
      resolve(&OrderResolver.nation_wide_delivery_fee_exists?/2)
    end
  end
end
