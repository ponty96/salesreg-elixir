defmodule SalesRegWeb.Services.Heroku do
  alias SalesRegWeb.Services.Base

  def create_domain(hostname) do
    body =
      %{"hostname" => hostname}
      |> Base.encode()

    request(:post, process_url(), body)
    |> Base.process_response()
  end

  def delete_domain(domain_id_or_host_name) do
    url = process_url() <> domain_id_or_host_name

    request(:delete, url, "")
    |> Base.process_response()
  end

  def list_domain(opts \\ []) do
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
      {:ok, body} = Poison.encode(
        %{message: "A request was made to Heroku"}
      )
      
      {:ok, 
        %HTTPoison.Response{status_code: 200, body: body}}
    end
  end

  defp process_url() do
    base_url = get_config_key_val(:api_base_url)
    app_id_or_name = get_config_key_val(:app_id_or_name)

    base_url <> app_id_or_name <> "/domains/"
  end

  defp get_config_key_val(key) do
    opts = Application.get_env(:sales_reg, __MODULE__)
    Keyword.get(opts, key)
  end
end
