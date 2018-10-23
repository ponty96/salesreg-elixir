defmodule SalesRegWeb.GraphQL.Resolvers.BankResolver do
  use SalesRegWeb, :context

  def upsert_bank(%{bank: params, bank_id: id}, _res) do
    Business.get_bank(id)
    |> Business.update_bank_details(params)
  end

  def upsert_bank(%{bank: params}, _res) do
    Business.create_bank(params)
  end

  def delete_bank(%{bank_id: bank_id}, _res) do
    Business.get_bank(bank_id)
    |> Business.delete_bank()
  end

  def list_company_banks(%{company_id: id}, _res) do
    Business.list_company_banks(id)
  end
end
