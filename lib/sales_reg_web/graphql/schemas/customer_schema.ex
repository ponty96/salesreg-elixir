defmodule SalesRegWeb.GraphQL.Schemas.CustomerSchema do
  @moduledoc """
    GraphQL Schemas for Customer
  """
  use Absinthe.Schema.Notation
  alias SalesRegWeb.GraphQL.Resolvers.CustomerResolver

  object :customer_mutations do
    @desc """
      mutation to create customer
    """
    field :add_customer, :mutation_response do
      arg(:customer, non_null(:customer_input))

      resolve(&customerResolver.add_customer/2)
    end

    @desc """
      mutation to update customer
    """
    field :update_customer, :mutation_response do
      arg(:customer, non_null(:update_customer_input))
      arg(:customer_id, non_null(:uuid))

      resolve(&CustomerResolver.update_customer/2)
    end

    @desc """
      mutation to delete customer
    """
    field :delete_customer, :mutation_response do
      arg(:customer_id, non_null(:uuid))

      resolve(&CustomerResolver.delete_customer/2)
    end
  end

  object :customer_queries do
    @desc """
      query all customers of a company
    """
    field :company_customers, list_of(:customer) do
      arg(:company_id, non_null(:uuid))

      resolve(&CustomerResolver.list_company_customers/2)
    end
  end
end
