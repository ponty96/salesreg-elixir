defmodule SalesRegWeb.GraphQL.Resolvers.SpecialOfferResolver do
  @moduledoc """
  Special Offer Resolver
  """
  use SalesRegWeb, :context

  def upsert_bonanza(%{bonanza_id: id, bonanza: bonanza_params}, _res) do
    id
    |> SpecialOffer.get_bonanza()
    |> SpecialOffer.update_bonanza(bonanza_params)
  end

  def upsert_bonanza(%{bonanza: bonanza_params}, _res) do
    SpecialOffer.add_bonanza(bonanza_params)
  end

  def list_company_bonanzas(%{company_id: company_id} = args, _res) do
    [company_id: company_id]
    |> SpecialOffer.paginated_list_company_bonanzas(pagination_args(args))
  end

  def get_bonanza(%{bonanza_id: id}, _res) do
    SpecialOffer.get_bonanza_if_not_expired(id)
  end

  defp pagination_args(args) do
    Map.take(args, [:first, :after, :last, :before])
  end
end
