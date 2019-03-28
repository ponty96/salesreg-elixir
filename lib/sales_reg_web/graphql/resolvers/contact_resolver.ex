defmodule SalesRegWeb.GraphQL.Resolvers.ContactResolver do
  @moduledoc """
  Contact Resolver
  """
  use SalesRegWeb, :context

  # MUTATIONS
  def upsert_contact(%{contact: params, contact_id: id}, _res) do
    id
    |> Business.get_contact()
    |> Business.update_contact(params)
  end

  def upsert_contact(%{contact: params}, _res) do
    params
    |> Business.add_contact()
  end

  def delete_contact(%{contact_id: contact_id}, _res) do
    contact_id
    |> Business.get_contact()
    |> Business.delete_contact()
  end

  # QUERIES
  def list_company_contacts(%{company_id: id, query: query, type: type} = args, _res) do
    [company_id: id, type: type]
    |> Business.search_company_contacts(query, :contact_name, pagination_args(args))
  end

  def search_customers_by_name(params, _res) do
    {:ok, Business.search_customers_by_name(params)}
  end

  # Private Functions
  defp pagination_args(args) do
    Map.take(args, [:first, :after, :last, :before])
  end
end
