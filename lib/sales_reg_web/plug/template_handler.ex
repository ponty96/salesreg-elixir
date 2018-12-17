defmodule SalesRegWeb.Plug.TemplateHandler do
  @behaviour Plug
  import Plug.Conn
  require Logger
  # Import convenience functions from controllers
  import Phoenix.Controller, only: [put_layout: 2, put_view: 2]

  def init(default), do: default

  def call(%Plug.Conn{host: host} = conn, _default) when is_binary(host) do
    conn
    |> fetch_and_add_view()
  end

  defp fetch_and_add_view(
         %Plug.Conn{assigns: %{company_template: %{template: %{slug: slug}}}} = conn
       ) do
    view = get_view(slug)

    conn
    |> put_layout({view, "app.html"})
    |> put_view(view)
  end

  defp get_view(slug) do
    template =
      slug
      |> String.split("-")
      |> Enum.at(0)
      |> String.capitalize()

    String.to_atom("Elixir.SalesRegWeb.Theme.#{template}View")
  end
end
