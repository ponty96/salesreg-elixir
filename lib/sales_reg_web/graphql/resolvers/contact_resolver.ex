defmodule SalesRegWeb.GraphQL.Resolvers.ContactResolver do
  use SalesRegWeb, :context

  def upsert_contact(%{contact: params, contact_id: id}, _res) do
    Business.update_contact(id, params)
  end

  def upsert_contact(%{contact: params}, _res) do
    params
    |> Business.add_contact()
  end

  def list_company_contacts(%{company_id: company_id, type: type}, _res) do
    Business.list_company_contacts(company_id, type)
  end

  def delete_contact(%{contact_id: contact_id}, _res) do
    Business.get_contact(contact_id)
    |> Business.delete_contact()
  end
end
