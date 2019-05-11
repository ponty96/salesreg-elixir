defmodule SalesReg.Mailer.YipcartToMerchants do
  @moduledoc """
    Module handling sending emails to merchants
  """
  use SalesRegWeb, :context
  import Bamboo.Email

  def send_welcome_mail(company) do
    html_body =
      "yc_email_welcome_to_yc"
      |> return_file_content()
      |> EEx.eval_string(company: company)

    subject = "Welcome to Yipcart #{company.slug}"

    company.contact_email
    |> send_email(html_body, subject)
  end

  def send_order_notification(sale) do
    sale = Order.preload_order(sale)

    html_body =
      "yc_email_order_notification"
      |> return_file_content()
      |> EEx.eval_string(sale: sale)

    subject = "New Order ##{sale.ref_id} created"

    sale.company.contact_email
    |> send_email(html_body, subject)
  end

  def send_invoice_payment_notice(sale) do
    sale = Order.preload_order(sale)

    html_body =
      "yc_email_invoice_payment_notice"
      |> return_file_content()
      |> EEx.eval_string(sale: sale)

    subject = "Payment Reminder Invoice ##{sale.invoice.ref_id}"

    sale.company.contact_email
    |> send_email(html_body, subject)
  end

  def send_invoice_due_notification(sale) do
    sale = Order.preload_order(sale)

    html_body =
      "yc_email_invoice_due_notification"
      |> return_file_content()
      |> EEx.eval_string(sale: sale)

    subject = "Payment Reminder Invoice ##{sale.invoice.ref_id}"

    sale.company.contact_email
    |> send_email(html_body, subject)
  end

  def send_restock_mail(sale) do
    sale = Order.preload_order(sale)

    html_body =
      "yc_email_restock"
      |> return_file_content()
      |> EEx.eval_string(sale: sale)

    subject = "Restock your items #{sale.company.slug}"

    sale.company.contact_email
    |> send_email(html_body, subject)
  end

  defp return_file_content(type) do
    {:ok, binary} =
      ("./lib/sales_reg_web/templates/mailer/#{type}" <> ".html.eex")
      |> Path.expand()
      |> File.read()

    binary
  end

  defp send_email(contact_email, html_body, subject) do
    new_email(
      from: "no-reply@yipcart.com",
      to: contact_email,
      subject: subject,
      html_body: html_body
    )
    |> Mailer.deliver_later()
  end
end
