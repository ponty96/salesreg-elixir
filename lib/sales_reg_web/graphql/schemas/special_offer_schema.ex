defmodule SalesRegWeb.GraphQL.Schemas.SpecialOfferSchema do
  @moduledoc """
    GraphQL Schemas for Theme
  """
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :classic
  alias SalesRegWeb.GraphQL.MiddleWares.Authorize
  alias SalesRegWeb.GraphQL.Resolvers.SpecialOfferResolver

  ## MUTATIONS
  object :special_offer_mutations do
    @desc """
    Upsert a special offer
    """
    field :upsert_bonanza, :mutation_response do
      arg(:bonanza, non_null(:bonanza_input))
      arg(:bonanza_id, :uuid)

      middleware(Authorize)
      resolve(&SpecialOfferResolver.upsert_bonanza/2)
    end
  end

  object :special_offer_queries do
    @desc """
    Query for all bonanzas of a company
    """
    connection field(:list_company_bonanzas, node_type: :bonanza) do
      arg(:company_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&SpecialOfferResolver.list_company_bonanzas/2)
    end
  end
end
