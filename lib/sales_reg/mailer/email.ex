defmodule SalesReg.Email do
  use SalesRegWeb, :context
  import Bamboo.Email
  require Logger

  def send_email(%Company{} = company, type, binary) do
    binary
    |> transform_template(company)
    |> construct_email(company, type)
    |> send_email()
  end

  def send_email(%Sale{} = sale, type, binary) do
    sale = Order.preload_order(sale)

    binary
    |> transform_template(sale)
    |> construct_email(sale, type)
    |> send_email()
  end

  def send_email(%Sale{} = sale, type) do
    sale = Order.preload_order(sale)
    company = sale.company

    company.id
    |> Theme.get_email_template_by_type(type)
    |> transform_template(sale)
    |> construct_email(sale, type)
    |> send_email()
  end

  def send_email(email_params) do
    new_email =
      new_email(
        from: email_params.from,
        to: email_params.to,
        subject: email_params.subject,
        html_body: email_params.html_body
      )

    if Mix.env() == :prod do
      Mailer.deliver_later(new_email)
    else
      Logger.info("Sending email to #{email_params.to}")

      %Bamboo.Email{
        from: email_params.from,
        to: email_params.to,
        subject: email_params.subject
      }
    end
  end

  defp transform_template(template, %Sale{} = sale) when is_map(template) do
    EEx.eval_string(template.body, sale: sale)
  end

  defp transform_template(binary, %Sale{} = sale) when is_binary(binary) do
    EEx.eval_string(binary, sale: Order.preload_order(sale))
  end

  defp transform_template(binary, %Company{} = company) do
    EEx.eval_string(binary, company: company)
  end

  defp construct_email(html_body, %Company{} = company, type) do
    %{
      to: company.contact_email,
      from: "hello@yipcart.com",
      subject: gen_sub(type),
      html_body: html_body
    }
  end

  defp construct_email(html_body, %Sale{} = sale, type) do
    %{
      to: sale.contact.email,
      from: sale.company.contact_email,
      subject: gen_sub(type),
      html_body: html_body
    }
  end

  defp gen_sub(type) do
    case type do
      "yc_email_before_due" ->
        "New Invoice Created"

      "yc_email_early_due" ->
        "Order Payment reminder"

      "yc_email_late_overdue" ->
        "Order Payement Overdue"

      "yc_email_received_order" ->
        "Received Order"

      "yc_email_reminder" ->
        "Payment Reminder"

      "yc_email_restock" ->
        "Restock"

      "yc_email_welcome_to_yc" ->
        "Welcome To YipCart"

      "yc_payment_received" ->
        "Payment Received"

      "yc_email_delivered_order" ->
        "Delivered Order"

      "yc_email_delivering_order" ->
        "Delivering Order"

      "yc_email_pending_delivery" ->
        "Pending Delivery"

      "yc_email_pending_order" ->
        "Pending Order"

      "yc_email_invoice_payment_notice" ->
        "Order Payment"

      "yc_email_order_notification" ->
        "New Order"

      "yc_email_invoice_due_notification" ->
        "Due Order"

      _ ->
        "No Subject"
    end
  end
end
