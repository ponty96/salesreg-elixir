defmodule SalesRegWeb.GraphQL.Schemas.BusinessSchema do
  @moduledoc """
    GraphQL Schemas for Company
  """
  use Absinthe.Schema.Notation
  alias SalesRegWeb.GraphQL.Resolvers.CompanyResolver
  alias SalesRegWeb.GraphQL.Resolvers.BankResolver
  alias SalesRegWeb.GraphQL.MiddleWares.Authorize

  object :company_mutations do
    @desc """
    mutation to start | register user
    """
    field :add_user_company, :mutation_response do
      arg(:user, non_null(:uuid))
      arg(:company, non_null(:company_input))

      middleware(Authorize)
      resolve(&CompanyResolver.register_company/2)
    end

    @desc """
    mutation to update | edit company
    """
    field :update_company, :mutation_response do
      arg(:id, non_null(:uuid))
      arg(:company, non_null(:company_input))

      resolve(&CompanyResolver.update_company/2)
    end
  end

  ### QUERIES
  object :bank_queries do
    @desc """
      query all banks of a company
    """
    field :company_banks, list_of(:bank) do
      arg(:company_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&BankResolver.list_company_banks/2)
    end
  end
end
