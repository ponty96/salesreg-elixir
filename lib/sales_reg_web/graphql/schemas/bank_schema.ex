defmodule SalesRegWeb.GraphQL.Schemas.BankSchema do
  @moduledoc """
    GraphQL Schemas for bank
  """
  use Absinthe.Schema.Notation
  alias SalesRegWeb.GraphQL.Resolvers.BankResolver
  alias SalesRegWeb.GraphQL.MiddleWares.Authorize

  ### MUTATIONS
  object :bank_mutations do
    @desc """
      upsert a bank
    """
    field :upsert_bank, :mutation_response do
      arg(:bank, non_null(:bank_input))
      arg(:bank_id, :uuid)

      middleware(Authorize)
      resolve(&BankResolver.upsert_bank/2)
    end

    @desc """
      mutation to delete bank
    """
    field :delete_bank, :mutation_response do
      arg(:bank_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&BankResolver.delete_bank/2)
    end
  end
end
