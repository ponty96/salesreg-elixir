if Mix.env() == :prod do 
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
      header = Application.get_env(:heroku, :default_header)
      HTTPoison.request(method, url, body, header, Base.set_default_timeout(opts))
    end

    defp process_url() do
      base_url = Application.get_env(:heroku, :base_url) 
      app_id_or_name = Application.get_env(:heroku, :app_id_or_name)

      base_url <> app_id_or_name <> "/domains/"
    end
  end

end

