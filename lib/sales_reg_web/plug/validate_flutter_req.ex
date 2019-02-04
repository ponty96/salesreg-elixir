defmodule SalesRegWeb.Plug.ValidateFlutterRequest do
  @behaviour Plug
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _options) do
    case get_req_header(conn, "verif-hash") do
      [secret_hash] ->
        verify_secret_hash(conn, secret_hash)

      _ ->
        conn
        |> resp(401, "Unauthorized")
        |> send_resp()
    end
  end

  defp verify_secret_hash(conn, secret_hash) do
    if System.get_env("FLUTTER_SECRET_HASH") == secret_hash do
      conn
    else
      conn
      |> resp(401, "Unauthorized")
      |> send_resp()
    end
  end
end
