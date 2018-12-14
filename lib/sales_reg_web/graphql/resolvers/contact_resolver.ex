defmodule SalesRegWeb.GraphQL.Resolvers.ContactResolver do
  use SalesRegWeb, :context

  # MUTATIONS
  def upsert_contact(%{contact: params, contact_id: id}, _res) do
    Business.get_contact(id)
    |> Business.update_contact(params)
  end

  def upsert_contact(%{contact: params}, _res) do
    params
    |> Business.add_contact()
  end

  def delete_contact(%{contact_id: contact_id}, _res) do
    Business.get_contact(contact_id)
    |> Business.delete_contact()
  end

  # QUERIES
  def list_company_contacts(%{company_id: company_id, type: type} = args, _res) do
    {:ok, contacts} = Business.list_company_contacts(company_id, type)

    contacts
    |> Absinthe.Relay.Connection.from_list(pagination_args(args))
  end

  def search_customers_by_name(params, _res) do
    {:ok, Business.search_customers_by_name(params)}
  end

  # Private Functions
  defp pagination_args(args) do
    Map.take(args, [:first, :after, :last, :before])
  end
end
