defmodule SalesReg.Order do
  @moduledoc """
  The Order context.
  """

  import Ecto.Query, warn: false
  use SalesRegWeb, :context
  alias Dataloader.Ecto, as: DataloaderEcto

  use SalesReg.Context, [
    Purchase,
    Sale
  ]

  def data do
    DataloaderEcto.new(Repo, query: &query/2)
  end

  def query(queryable, _) do
    queryable
  end
end
