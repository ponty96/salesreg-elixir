defmodule SalesRegWeb.GraphQL.Schemas.BusinessSchema do
  @moduledoc """
    GraphQL Schemas for Company
  """
  use Absinthe.Schema.Notation
  alias SalesRegWeb.GraphQL.Resolvers.CompanyResolver

  object :company_mutations do
    @desc """
    mutation to start | register user
    """
    field :register_company, :mutation_response do
      arg(:user, non_null(:user_input))
      arg(:company, non_null(:company_input))

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
end
