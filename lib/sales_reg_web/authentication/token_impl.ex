defmodule SalesRegWeb.TokenImpl do
  @moduledoc """
  Guardian Token handler
  """
  alias SalesReg.Accounts

  use Guardian, otp_app: :sales_reg

  def subject_for_token(user, _claims) do
    sub = to_string(user.id)
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    resource = Accounts.get_user(id)
    {:ok, resource}
  end

  def after_encode_and_sign(resource, claims, token, _options) do
    with {:ok, _} <- Guardian.DB.after_encode_and_sign(resource, claims["typ"], claims, token) do
      {:ok, token}
    end
  end

  def on_verify(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_verify(claims, token) do
      {:ok, claims}
    end
  end

  def on_exchange({old_token, old_claim}, {token, claim}, _opts) do
    id = old_claim["sub"]
    resource = Accounts.get_user(id)
    {:ok, _} = Guardian.DB.after_encode_and_sign(resource, claim["typ"], claim, token)
    {:ok, {old_token, old_claim}, {token, claim}}
  end

  def on_refresh({old_token, old_claims}, {new_token, new_claims}, _options) do
    with {:ok, _, _} <- Guardian.DB.on_refresh({old_token, old_claims}, {new_token, new_claims}) do
      {:ok, {old_token, old_claims}, {new_token, new_claims}}
    end
  end

  def on_revoke(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_revoke(claims, token) do
      {:ok, claims}
    end
  end
end
