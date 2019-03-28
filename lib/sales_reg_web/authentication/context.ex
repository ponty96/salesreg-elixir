defmodule SalesRegWeb.AbsintheContext do
  @moduledoc """
  Absinthe Context Module
  """
  @behaviour Plug
  import Plug.Conn
  alias SalesRegWeb.TokenImpl

  def init(opts), do: opts

  def call(conn, _) do
    case build_context(conn) do
      {:ok, context} ->
        put_private(conn, :absinthe, %{context: context})

      {:error, _reason} ->
        conn

      _ ->
        conn
    end
  end

  @doc """
  Return the current user context based on the authorization header
  """
  def build_context(conn) do
    with [token] <- get_req_header(conn, "authorization"),
         company <- conn.assigns[:company],
         {:ok, current_user} <- authorize(token) do
      {:ok, %{current_user: current_user, company: company}}
    else
      _error ->
        company = conn.assigns[:company]
        {:ok, %{company: company}}
    end
  end

  defp authorize(token) do
    case TokenImpl.decode_and_verify(token) do
      {:ok, claims} ->
        IO.puts("got called in claims")
        return_user(claims)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp return_user(claims) do
    case TokenImpl.resource_from_claims(claims) do
      {:ok, resource} -> {:ok, resource}
      {:error, reason} -> {:error, reason}
    end
  end
end
