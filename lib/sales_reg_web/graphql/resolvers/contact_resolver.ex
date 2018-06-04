defmodule SalesRegWeb.GraphQL.Resolvers.ContactResolver do
  use SalesRegWeb, :context

  def add_contact(%{contact: params}, _res) do
    Business.add_contact(params)
  end

  def update_contact(%{contact: params, contact_id: contact_id}, _res) do
    {:ok, contact} = Business.get_contact(contact_id)

    contact
    |> Business.update_contact(params)
  end

  def list_company_contacts(%{company_id: company_id} = another, _res) do
    Business.list_company_contacts(company_id)
  end

  def delete_contact(%{contact_id: contact_id}, _res) do
    {:ok, contact} = Business.get_contact(contact_id)

    Business.delete_contact(contact)
  end
end
