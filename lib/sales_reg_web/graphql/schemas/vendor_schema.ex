defmodule SalesRegWeb.GraphQL.Schemas.VendorSchema do
  @moduledoc """
    GraphQL Schemas for Store
  """
  use Absinthe.Schema.Notation
  alias SalesRegWeb.GraphQL.Resolvers.VendorResolver

	# Mutations
  object :vendor_mutations do
    @desc """
        add vendor
    """
    field :add_vendor, :mutation_response do
      arg(:vendor, non_null(:vendor_input))

      resolve(&VendorResolver.add_vendor/2)
    end

    @desc """
      update a vendor
    """
    field :update_vendor, :mutation_response do
      arg(:vendor, non_null(:update_vendor_input))
			arg(:vendor_id, non_null(:uuid))

      resolve(&VendorResolver.update_vendor/2)
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
