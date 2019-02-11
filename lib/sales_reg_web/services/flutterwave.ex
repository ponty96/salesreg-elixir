if Mix.env() == :prod do
  defmodule SalesRegWeb.Services.Flutterwave do
    alias SalesRegWeb.Services.Base

    @base_url "https://ravesandboxapi.flutterwave.com/"
    @flutterwave_secret_key System.get_env("FLUTTERWAVE_SECRET_KEY")

    def create_subaccount(params) do
      body = params
        |> construct_subaccount_details()
        |> Base.encode()

      :post 
      |> request(process_url("v2/gpx/subaccounts/create"), body)
      |> Base.process_response()
    end

    def update_subaccount(params, id) do
      body = params
        |> construct_subaccount_details()
        |> Map.delete("business_mobile")
        |> Map.delete("seckey")
        |> Map.put("id", id)
        |> Base.encode()

      :post
      |> request(process_url("v2/gpx/subaccounts/edit"), body)
      |> Base.process_response()
    end

    def list_subaccount() do
      endpoint = process_url("v2/gpx/subaccounts?seckey=#{@flutterwave_secret_key}")

      request(:get, endpoint, "")
      |> Base.process_response()
    end

    def delete_subaccount(id) do
      endpoint = process_url("v2/gpx/subaccounts/delete")
      body = 
        %{
          "id" => id,
          "seckey" => @flutterwave_secret_key
        } 
        |> Base.encode()

      request(:delete, endpoint, body)
      |> Base.process_response()
    end

    defp request(method, endpoint, body, opts \\ []) do
      header = [{"Content-Type", "application/json"}]

      HTTPoison.request(
        method,
        endpoint, 
        body, 
        header, 
        Base.set_default_timeout(opts)
      )
    end

    defp process_url(endpoint) do
      @base_url <> endpoint
    end

    defp construct_subaccount_details(params) do
      %{
        "account_bank" => params.account_bank,
        "account_number" => params.account_number,
        "business_name" => params.business_name,
        "business_email" => params.business_email,
        "business_mobile" => params.business_mobile,
        "seckey" => @flutterwave_secret_key,
        "split_type" => "percentage",
        "split_value" => "0.05"
      }
    end
  end
end