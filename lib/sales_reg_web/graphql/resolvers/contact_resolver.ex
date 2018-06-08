defmodule SalesRegWeb.GraphQL.Resolvers.ContactResolver do
  use SalesRegWeb, :context

  @phone_types ["home", "work", "mobile"]
  
  def add_contact(%{contact: %{phones: phones} = params}, _res) do
    params
    |> add_phones_type(phones)
    |> Business.add_contact()
  end

  def update_contact(%{contact: %{phones: phones} = params, contact_id: contact_id}, _res) do
    update_params = params
      |> add_phones_type(phones) 
    
    Business.get_contact(contact_id)
    |> Business.update_contact(update_params)
  end

  def list_company_contacts(%{company_id: company_id}, _res) do
    another = Business.list_company_contacts(company_id)
  end

  def delete_contact(%{contact_id: contact_id}, _res) do
    Business.get_contact(contact_id)
    |> Business.delete_contact()
  end

  defp add_phones_type(params, phones) do
    phones = phones
      |> Enum.map(fn(map) -> 
            randomize_type(map) 
          end)

    %{params | phones: phones}
  end

  defp randomize_type(map) do
    add_type = Map.put_new(map, :type, Enum.random(@phone_types))

    add_type
  end
 end
