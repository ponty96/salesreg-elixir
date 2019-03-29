defmodule SalesRegWeb.AuthPipeline do
  @moduledoc """
  Auth Plug Pipeline Module
  """
  use Guardian.Plug.Pipeline,
    otp_app: :sales_reg,
    module: SalesRegWeb.Guardian,
    error_handler: SalesRegWeb.AuthErrorHandler

  # If there is an authorization header, validate it
  plug(Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"})
  # If there is a session token, validate it
  plug(Guardian.Plug.VerifySession, claims: %{"typ" => "access"})
  # Load the user if either of the verifications worked
  plug(Guardian.Plug.LoadResource, allow_blank: true)
end
