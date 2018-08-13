defmodule SalesRegWeb.GraphQL.MiddleWares.Authorize do
  @behaviour Absinthe.Middleware

  def call(resolution, _config) do
    # IO.inspect(resolution, label: "resolution")
    IO.inspect(resolution.context, label: "resolution context")

    case resolution.context do
      %{current_user: _} ->
        resolution

      _ ->
        resolution
        |> Absinthe.Resolution.put_result({:error, "Not authenticated"})
    end
  end
end
