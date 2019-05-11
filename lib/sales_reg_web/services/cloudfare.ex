defmodule SalesRegWeb.Services.Cloudfare do
  @moduledoc """
  Cloudflare HTTP Client
  """
  alias SalesRegWeb.Services.Base

  def create_dns_record(type, name, content, optional_params \\ %{})
      when is_map(optional_params) == true do
    body =
      %{
        "type" => type,
        "name" => name,
        "content" => content,
        "proxied" => true
      }
      |> Map.merge(optional_params)
      |> Base.encode()

    request(:post, process_url(), body)
    |> Base.process_response()
  end

  def delete_dns_record(identifier) do
    url = process_url() <> identifier

    request(:delete, url, "")
    |> Base.process_response()
  end

  def list_dns_records(opts \\ []) do
    request(:get, process_url(), "", opts)
    |> Base.process_response()
  end

  defp request(method, url, body, opts \\ []) do
    header = get_config_key_val(:default_header)

    if Mix.env() == :prod do
      HTTPoison.request(
        method,
        url,
        body,
        header,
        Base.set_default_timeout(opts)
      )
    else
      {:ok, body} = Poison.encode(%{message: "A request was made to Cloudflare"})

      {:ok, %HTTPoison.Response{status_code: 200, body: body}}
    end
  end

  defp process_url do
    base_url = get_config_key_val(:api_base_url)
    zone_id = get_config_key_val(:zone_id)

    base_url <> zone_id <> "/dns_records/"
  end

  defp get_config_key_val(key) do
    opts = Application.get_env(:sales_reg, __MODULE__)
    Keyword.get(opts, key)
  end
end
