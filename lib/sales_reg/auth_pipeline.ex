
defmodule SalesReg.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :sales_reg,
    module: SalesReg.Guardian

  # If there is a session token, validate it
  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug(Guardian.Plug.EnsureAuthenticated)
  # If there is an authorization header, validate it
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  # Load the user if either of the verifications worked
  plug Guardian.Plug.LoadResource, allow_blank: true
end