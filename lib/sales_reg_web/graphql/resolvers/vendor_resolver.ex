defmodule SalesRegWeb.GraphQL.Resolvers.VendorResolver do
  use SalesRegWeb, :context

  def add_vendor(%{vendor: params}, _res) do
    Business.add_vendor(params)
  end

  def update_vendor(%{vendor: params, vendor_id: vendor_id}, _res) do
    Business.get_vendor(vendor_id)
    |> Business.update_vendor(params)
  end

  def list_company_vendors(%{company_id: company_id}, _res) do
    Business.list_company_vendors(company_id)
  end
end
