defmodule SalesRegWeb.Services.Flutterwave do
  alias SalesRegWeb.Services.Base

  def create_subaccount(params) do
    body =
      params
      |> construct_subaccount_details()
      |> Base.encode()

    :post
    |> request(process_url("v2/gpx/subaccounts/create"), body)
    |> Base.process_response()
  end

  def update_subaccount(params, id) do
    body =
      params
      |> construct_subaccount_details()
      |> Map.delete("business_mobile")
      |> Map.put("id", id)
      |> Base.encode()

    :post
    |> request(process_url("v2/gpx/subaccounts/edit"), body)
    |> Base.process_response()
  end

  def list_subaccount() do
    endpoint = process_url("v2/gpx/subaccounts?seckey=#{get_flutterwave_key()}")

    request(:get, endpoint, "")
    |> Base.process_response()
  end

  def delete_subaccount(id) do
    endpoint = process_url("v2/gpx/subaccounts/delete")

    body =
      %{
        "id" => id,
        "seckey" => get_flutterwave_key()
      }
      |> Base.encode()

    request(:delete, endpoint, body)
    |> Base.process_response()
  end

  defp request(method, endpoint, body, opts \\ []) do
    header = [{"Content-Type", "application/json"}]

    if Mix.env() == :prod do
      HTTPoison.request(
        method,
        endpoint,
        body,
        header,
        Base.set_default_timeout(opts)
      )
    else
      {:ok, body} = Poison.encode(%{"data" => %{"subaccount_id" => "12345", "id" => "0001"}})

      {:ok, %HTTPoison.Response{status_code: 200, body: body}}
    end
  end

  defp process_url(endpoint) do
    get_flutterwave_api() <> endpoint
  end

  defp construct_subaccount_details(params) do
    %{
      "account_bank" => params.account_bank,
      "account_number" => params.account_number,
      "business_name" => params.business_name,
      "business_email" => params.business_email,
      "business_mobile" => params.business_mobile,
      "seckey" => get_flutterwave_key(),
      "split_type" => "percentage",
      "split_value" => "#{System.get_env("CHARGE")}"
    }
  end

  defp get_flutterwave_key do
    # A fallback value is used here incase of test environment
    System.get_env("FLUTTERWAVE_SECRET_KEY") || "flutterwave-test-secret-key"
  end

  defp get_flutterwave_api do
    # A fallback value is used here incase of test environemt
    System.get_env("FLUTTERWAVE_API") || "flutterwave-test-api"
  end
end
