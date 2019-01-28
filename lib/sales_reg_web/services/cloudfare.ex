if Mix.env() == :prod do 
  defmodule SalesRegWeb.Services.Cloudfare do
    alias SalesRegWeb.Services.Base
  
    def create_dns_record(type, name, content, optional_params \\ %{}) when is_map(optional_params) == true  do
      body =
        %{
          "type" => type,
          "name" => name,
          "content" => content
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
      header = Application.get_env(:cloudfare, :default_header)
      HTTPoison.request(method, url, body, header, Base.set_default_timeout(opts))
    end

    defp process_url() do
      base_url = Application.get_env(:cloudfare, :api_base_url) 
      zone_id = Application.get_env(:cloudfare, :zone_id)
    
      base_url <> zone_id <> "/dns_records/"
    end
  end

end