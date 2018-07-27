defmodule SalesRegWeb.GraphQL.Schemas.CompanySchema do
  @moduledoc """
    GraphQL Schemas for Company
  """
  use Absinthe.Schema.Notation
  alias SalesRegWeb.GraphQL.Resolvers.CompanyResolver

  @desc """
  mutation to start | register user
  """
  object :register_company do
    field :register_company, :mutation_response do
      arg(:user, non_null(:user_input))
      arg(:company, non_null(:company_input))

      resolve(&CompanyResolver.register_company/2)
    end
  end
end
