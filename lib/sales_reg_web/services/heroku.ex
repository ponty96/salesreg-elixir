if Mix.env == :prod do
  defmodule SalesReg.Heroku do

    def create_domain(domain) do
      body = %{"hostname" => domain}
    
      request(:post, process_url(), encode(body))
      |> process_response
    end

    def delete_domain(domain_id_or_host_name) do
      url = process_url() <> domain_id_or_host_name
    
      request(:delete, url, "")
      |> process_response
    end

    def list_domain() do
      request(:get, process_url(), "")
      |> process_response
    end

    defp process_response({:ok,
      %HTTPoison.Response{status_code: status} = response
    }) when status in 200..201 do  
      Poison.decode!(response.body)
    end

    defp process_response({:ok,
      %HTTPoison.Response{status_code: _status} = response
    }) do  
      Poison.decode!(response.body)
    end

    defp process_response({:error, response}) do  
      IO.inspect response, label: "Request Response"
      response.reason
    end

    defp encode(params) do
      Poison.encode!(params)
    end

    defp request(method, url, body, header \\ [], options \\ []) do
      header = Application.get_env(:heroku, :default_header) ++ header
      HTTPoison.request(method, url, body, header, options)
    end

    defp process_url() do
      base_url = Application.get_env(:heroku, :base_url) 
      app_id_or_name = Application.get_env(:heroku, :app_id_or_name)

      base_url <> app_id_or_name <> "/domains/"
    end
  end

end