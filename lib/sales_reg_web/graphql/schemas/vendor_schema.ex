defmodule SalesRegWeb.GraphQL.Schemas.VendorSchema do
  @moduledoc """
    GraphQL Schemas for Store
  """
  use Absinthe.Schema.Notation
  alias SalesRegWeb.GraphQL.Resolvers.VendorResolver

  # Mutations
  object :vendor_mutations do
    @desc """
      upsert a vendor
    """
    field :upsert_vendor, :mutation_response do
      arg(:vendor, non_null(:vendor_input))
      arg(:vendor_id, :uuid)

      resolve(&VendorResolver.upsert_vendor/2)
    end
  end

  # Queries
  object :vendor_queries do
    @desc """
      query for all vendors of a company
    """
    field :list_company_vendors, list_of(:vendor) do
      arg(:company_id, non_null(:uuid))

      resolve(&VendorResolver.list_company_vendors/2)
    end
  end
end
