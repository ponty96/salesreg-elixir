defmodule SalesReg.Email do
  use SalesRegWeb, :context
  import Bamboo.Email
  require Logger

  def send_email(to, sub, html_body \\ "", text_body \\ "") do
    new_email(
      from: "no-reply@yipcart.com",
      to: to,
      subject: sub,
      text_body: text_body,
      html_body: html_body
    )
    |> Mailer.deliver_later()
  end
end
