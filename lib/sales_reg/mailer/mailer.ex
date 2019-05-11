defmodule SalesReg.Mailer do
  @moduledoc """
    Mailer Module
  """
  use Bamboo.Mailer, otp_app: :sales_reg

  def naive_date(date) when is_binary(date) do
    {:ok, date} = Timex.parse(date, "{YYYY}-{0M}-{D}")
    date
  end

  def reset_pass_params(receipient, url) do
    params = %{
      from: "hello@yipcart.com",
      to: receipient,
      subject: "Password Reset",
      html_body: ""
    }

    text_body = """
      You requested for a password reset. Click on this link to reset your password:
      #{url}
    """

    {params, text_body}
  end
end
