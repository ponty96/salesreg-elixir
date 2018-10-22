defmodule SalesRegWeb.GraphQL.Resolvers.BankResolver do
  use SalesRegWeb, :context

  def upsert_bank(%{bank: params, bank_id: id}, _res) do
    Business.get_bank(id)
    |> Business.update_bank(params)
  end

  def upsert_bank(%{bank: params}, _res) do
    params
    |> Business.add_bank()
  end
  
  def delete_bank(%{bank_id: bank_id}, _res) do
    Business.get_bank(bank_id)
    |> Business.delete_bank()
  end
end
