defmodule SalesReg.Repo do
  use Ecto.Repo,
    otp_app: :sales_reg,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 12

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end

  def execute_and_load(sql, params, model) do
    result = Ecto.Adapters.SQL.query!(__MODULE__, sql, params)
    Enum.map(result.rows, &SalesReg.Repo.load(model, {result.columns, &1}))
  end
end
