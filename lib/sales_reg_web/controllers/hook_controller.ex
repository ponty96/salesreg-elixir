defmodule SalesRegWeb.HookController do
  use SalesRegWeb, :controller
  alias SalesReg.WebhookHandler

  def hook(conn, %{"status" => "successful"} = params) do
    receipt = WebhookHandler.insert_receipt(params)

    case receipt do
      {:ok, _receipt} ->
        put_status(conn, 200)
        |> json("Successful")

      _ ->
        put_status(conn, 200)
        |> json("Transaction already occurred")
    end
  end
end
