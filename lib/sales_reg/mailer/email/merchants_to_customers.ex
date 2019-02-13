defmodule SalesReg.Mailer.MerchantsToCustomers do
  use SalesRegWeb, :context
  import Bamboo.Email

  def send_reminder(sale) do
    sale = Order.preload_order(sale)
    subject = "Payment Reminder Invoice ##{sale.invoice.ref_id}"

    sale
    |> eval_and_send_email("yc_email_reminder", subject)
  end

  def send_before_due_mail(sale) do
    sale = Order.preload_order(sale)
    subject = "Invoice ##{sale.invoice.ref_id} created"

    sale
    |> eval_and_send_email("yc_email_before_due", subject)
  end

  def send_delivered_order_mail(sale) do
    sale = Order.preload_order(sale)
    subject = "Delivered Order ##{sale.ref_id}"

    sale
    |> eval_and_send_email("yc_email_delivered_order", subject)
  end

  def send_delivering_order_mail(sale) do
    sale = Order.preload_order(sale)
    subject = "Delivering Order ##{sale.ref_id}"

    sale
    |> eval_and_send_email("yc_email_delivering_order", subject)
  end

  def send_early_due_mail(sale) do
    sale = Order.preload_order(sale)
    subject = "Payment Reminder Invoice ##{sale.invoice.ref_id}"

    sale
    |> eval_and_send_email("yc_email_early_due", subject)
  end

  def send_late_overdue_mail(sale) do
    sale = Order.preload_order(sale)
    subject = "Payment Reminder Invoice ##{sale.invoice.ref_id}"

    sale
    |> eval_and_send_email("yc_email_late_overdue", subject)
  end

  def send_pending_delivery_mail(sale) do
    sale = Order.preload_order(sale)
    subject = "Pending Delivery Order ##{sale.ref_id}"

    sale
    |> eval_and_send_email("yc_email_pending_delivery", subject)
  end

  def send_pending_order_mail(sale) do
    sale = Order.preload_order(sale)
    subject = "Pending Order ##{sale.ref_id}"

    sale
    |> eval_and_send_email("yc_email_pending_order", subject)
  end

  def send_received_order_mail(sale) do
    sale = Order.preload_order(sale)
    subject = "Order Received"

    sale
    |> eval_and_send_email("yc_email_received_order", subject)
  end

  def send_payment_received_mail(sale) do
    sale = Order.preload_order(sale)
    subject = "Payment on invoice ##{sale.invoice.ref_id}"

    sale
    |> eval_and_send_email("yc_payment_received", subject)
  end

  def eval_and_send_email(sale, type, subject) do
    template =
      sale.company.id
      |> Theme.get_email_template_by_type(type)

    eval_html_body = EEx.eval_string(template.body, sale: sale)

    sale
    |> send_email(eval_html_body, subject)
  end

  defp send_email(sale, html_body, subject) do
    new_email(
      from: sale.company.contact_email,
      to: sale.contact.email,
      subject: subject,
      html_body: html_body
    )
    |> Mailer.deliver_later()
  end
end
