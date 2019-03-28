defmodule SalesRegWeb.Plug.TemplateHandler do
  @moduledoc """
  Template handler module
  """
  @behaviour Plug
  import Plug.Conn
  require Logger
  # Import convenience functions from controllers
  import Phoenix.Controller, only: [put_layout: 2, put_view: 2]
  alias SalesReg.Store

  def init(default), do: default

  def call(%Plug.Conn{host: host} = conn, _default) when is_binary(host) do
    conn
    |> fetch_and_add_view()
  end

  defp fetch_and_add_view(
         %Plug.Conn{
           assigns: %{company_template: %{template: %{slug: slug}}, company_id: company_id}
         } = conn
       ) do
    view = get_view(slug)
    categories = Store.home_categories(company_id)

    conn
    |> put_layout({view, "app.html"})
    |> put_view(view)
    |> assign(:footer_categories, categories)
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
