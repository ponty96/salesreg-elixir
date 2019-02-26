defmodule SalesReg.SpecialOffer do
  @moduledoc """
  The Special Offer context.
  """
  use SalesRegWeb, :context
  alias Dataloader.Ecto, as: DataloaderEcto

  use SalesReg.Context, [
    Bonanza,
    BonanzaItem
  ]

  defdelegate get_bonanza_share_url(bonanza), to: Bonanza

  def data do
    DataloaderEcto.new(Repo, query: &query/2)
  end

  def query(queryable, _) do
    queryable
  end

  def get_bonanza_if_not_expired(id) do
    bonanza = Repo.get(Bonanza, id)

    if bonanza_expired?(bonanza) == false do
      {:ok, bonanza}
    else
      {:ok, %{}}
    end
  end

  defp bonanza_expired?(bonanza) do
    {:ok, end_date} = Timex.parse(bonanza.end_date, "{YYYY}-{0M}-{D}")

    if Date.compare(Date.utc_today(), end_date) == :gt do
      true
    else
      false
    end
  end
end
