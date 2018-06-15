defmodule SalesRegWeb.GraphQL.Schemas.OrderSchema do
  @moduledoc """
    GraphQL Schemas for Order
  """
  use Absinthe.Schema.Notation
  alias SalesRegWeb.GraphQL.Resolvers.OrderResolver

  ### MUTATIONS
  object :purchase_mutations do
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
  end

  ### QUERIES
  object :purchase_queries do
    @desc """
      query for all purchases of a vendor
    """
    field :list_vendor_purchases, list_of(:purchase) do
      arg(:vendor_id, non_null(:uuid))

      resolve(&OrderResolver.list_vendor_purchases/2)
    end
  end
end
