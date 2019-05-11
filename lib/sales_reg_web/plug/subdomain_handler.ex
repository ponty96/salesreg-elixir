defmodule SalesRegWeb.Plug.SubdomainHandler do
  @moduledoc """
  Subdomain handler module confirms if company in request header exists
  """
  @behaviour Plug
  import Plug.Conn
  require Logger
  alias SalesReg.Business
  alias SalesReg.Business.Company

  def init(default), do: default

  def call(conn, _default) do
    headers = Enum.into(conn.req_headers, %{})
    conn = handle_request(headers, conn)

    assign_user(headers, conn)
  end

  defp handle_request(%{"request-endpoint" => endpoint}, conn) do
    endpoint
    |> URI.parse()
    |> Map.get(:authority)
    |> String.split(".")
    |> Enum.at(0)
    |> business?(conn)
  end

  defp assign_user(%{"companyid" => company_id, "userid" => user_id}, conn) do
    conn
    |> assign(:company_id, company_id)
    |> assign(:user_id, user_id)
  end

  defp assign_user(_headers, conn) do
    conn
    |> assign(:company_id, "")
    |> assign(:user_id, "")
  end

  defp handle_request(_headers, conn), do: assign(conn, :company, %{})

  defp business?(name, conn) do
    res = Business.get_company_by_slug(name)
    # Logger.info(fn -> "Get business by slug: #{res}" end)
    case res do
      nil ->
        handle_404_redirect(conn)

      %Company{} = company ->
        conn
        |> assign(:company_id, company.id)
        |> assign(:company, company)
        |> assign(:company_template, company.company_template)
    end
  end

  defp handle_404_redirect(conn) do
    Phoenix.Controller.redirect(conn, external: "http://yipcart.com/error/404")
  end
end
