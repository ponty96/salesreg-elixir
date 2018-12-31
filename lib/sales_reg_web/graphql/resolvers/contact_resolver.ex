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
  def list_company_contacts(%{company_id: id, query: query, type: type} = args, _res) do
    {:ok, %{edges: edges} = result} =
      Business.search_company_contacts(id, query, :contact_name, pagination_args(args))

    {:ok,
     %{
       result
       | edges:
           Enum.filter(
             edges,
             &(&1.node.type == type)
           )
     }}
  end

  def search_customers_by_name(params, _res) do
    {:ok, Business.search_customers_by_name(params)}
  end

  # Private Functions
  defp pagination_args(args) do
    Map.take(args, [:first, :after, :last, :before])
  end
end
