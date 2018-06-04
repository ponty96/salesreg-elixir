defmodule SalesRegWeb.GraphQL.Schemas.ContactSchema do
  @moduledoc """
    GraphQL Schemas for Company
  """
  use Absinthe.Schema.Notation
  alias SalesRegWeb.GraphQL.Resolvers.ContactResolver

  object :contact_mutations do
    @desc """
      mutation to create contact
    """
    field :add_contact, :mutation_response do
      arg(:contact, non_null(:contact_input))

      resolve(&ContactResolver.add_contact/2)
    end

    @desc """
      mutation to update contact
    """
    field :update_contact, :mutation_response do
      arg(:contact, non_null(:contact_input))
      arg(:contact_id, non_null(:uuid))

      resolve(&ContactResolver.update_contact/2)
    end

    @desc """
      mutation to delete contact
    """
    field :delete_contact, :mutation_response do
      arg(:contact_id, non_null(:uuid))

      resolve(&ContactResolver.delete_contact/2)
    end
  end

  object :contact_queries do
    @desc """
      query all contacts of a company
    """
    field :company_contacts, list_of(:contact) do
      arg(:company_id, non_null(:uuid))

      resolve(&ContactResolver.list_company_contacts/2)
    end
  end
end
