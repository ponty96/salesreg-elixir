defmodule SalesRegWeb.HookController do
  use SalesRegWeb, :controller
  alias SalesReg.WebhookHandler
  alias SalesRegWeb.Services.Base

  def hook(conn, %{"status" => "successful"} = params) do
    with true <- transaction_exist?(params),
         {:ok, _receipt} <- WebhookHandler.insert_receipt(params) do
      put_status(conn, 200)
      |> json("Successful")
    else
      _ ->
        put_status(conn, 200)
        |> json("Unsuccessful")
    end
  end

  defp transaction_exist?(params) do
    case verify_transaction(params) do
      %{"status" => "success"} ->
        true

      _ ->
        false
    end
  end

  defp verify_transaction(params) do
    url = System.get_env("FLUTTERWAVE_API") <> "flwv3-pug/getpaidx/api/v2/verify"

    body =
      %{
        "txref" => params["txRef"],
        "SECKEY" => System.get_env("FLUTTERWAVE_SECRET_KEY")
      }
      |> Base.encode()

    {:ok, _, body} =
      Base.request(:post, url, body)
      |> Base.process_response()

    body
  end
end
