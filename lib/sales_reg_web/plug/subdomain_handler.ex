defmodule SalesRegWeb.Plug.SubdomainHandler do
  @behaviour Plug
  import Plug.Conn
  require Logger
  alias SalesReg.Business

  def init(default), do: default

  def call(%Plug.Conn{host: host} = conn, _default) when is_binary(host) do
    host
    |> business_from_host(conn)
  end

  defp business_from_host(host, conn) do
    host
    |> String.split(".")
    |> subdomain?(conn)
  end

  defp subdomain?(enum, conn) do
    case Enum.count(enum) do
      # http://yipcart.com or yipcart.com
      2 ->
        # this should redirect to the yipcart landing page, as this app should only be available to app.yipcart.com or business_name.yipcart.com
        conn

      # www.business_name.yipcart.com
      4 ->
        Enum.at(enum, 2)
        |> business?(conn)

      # www.yipcart.com
      # app.yipcart.com
      # http://business_name.yipcart.com
      # business_name.yipcart.com
      3 ->
        [h | t] = enum

        case h do
          "www" ->
            # this should redirect to the yipcart landing page, as this app should only be available to app.yipcart.com or business_name.yipcart.com
            conn

          "app" ->
            # only allow api endpoints
            confirm_and_handle_api_request(conn)

          h ->
            business?(h, conn)
        end
    end
  end

  defp confirm_and_handle_api_request(%Plug.Conn{request_path: request_path} = conn) do
    case String.starts_with?(request_path, "/api") do
      true -> conn
      _ -> handle_404_redirect(conn)
    end
  end

  defp business?(name, conn) when is_binary(name) do
    case Business.get_company_by_slug(name) do
      nil ->
        handle_404_redirect(conn)

      company ->
        conn
        |> assign(:company_id, company.id)
        |> assign(:company, company)
        |> assign(:company_template, company.company_template)
    end
  end

  # when a business name is not a binary or pr
  defp business?(_name, conn) do
    handle_404_redirect(conn)
  end

  defp handle_404_redirect(conn) do
    Phoenix.Controller.redirect(conn, external: "http://yipcart.com/error/404")
  end
end
