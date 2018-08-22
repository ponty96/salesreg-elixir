defmodule SalesReg.Store do
  @moduledoc """
  The Store context.
  """

  import Ecto.Query, warn: false
  alias SalesReg.Repo
  use SalesRegWeb, :context

  use SalesReg.Context, [
    Product,
    Service
  ]

  defmacro search_schema_by_field(schema, query, field) do
    quote do
      unquote(schema)
      |> select([s], map(s, [unquote(field), :id]))
      |> where(
        [s],
        fragment("text(?) @@ plainto_tsquery(?)", field(s, ^unquote(field)), ^unquote(query))
      )
      |> order_by(
        [s],
        fragment(
          "ts_rank(to_tsvector(?), plainto_tsquery(?)) DESC",
          field(s, ^unquote(field)),
          ^unquote(query)
        )
      )
      |> Repo.all()
    end
  end
end
