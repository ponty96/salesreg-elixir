defmodule SalesRegWeb.GraphQL.Schemas.ContactSchema do
  @moduledoc """
    GraphQL Schemas for Contact
  """
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :classic
  alias SalesRegWeb.GraphQL.Resolvers.ContactResolver
  alias SalesRegWeb.GraphQL.MiddleWares.Authorize

  ### MUTATIONS
  object :contact_mutations do
    @desc """
      upsert a contact
    """
    field :upsert_contact, :mutation_response do
      arg(:contact, non_null(:contact_input))
      arg(:contact_id, :uuid)

      middleware(Authorize)
      resolve(&ContactResolver.upsert_contact/2)
    end

    @desc """
      mutation to delete contact
    """
    field :delete_contact, :mutation_response do
      arg(:contact_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&ContactResolver.delete_contact/2)
    end
  end

  ### QUERIES
  object :contact_queries do
    @desc """
      query all contacts of a company
    """
    connection field(:company_contacts, node_type: :contact) do
      arg(:company_id, non_null(:uuid))
      arg(:type, non_null(:string))
      arg(:query, :string)

      middleware(Authorize)
      resolve(&ContactResolver.list_company_contacts/2)
    end

    @desc """
      query all customers of a company
    """
    field :company_customers, list_of(:contact) do
      arg(:company_id, non_null(:uuid))
      arg(:name, non_null(:string))

      middleware(Authorize)
      resolve(&ContactResolver.search_customers_by_name/2)
    end
  end
end
