defmodule SalesReg.Tasks do
  use SalesRegWeb, :context
  alias SalesReg.Mailer.YipcartToCustomers, as: YC2C
  alias SalesReg.Mailer.MerchantsToCustomers, as: M2C
  alias SalesRegWeb.Services.Base
  require Logger

  # sends emails on the day orders are due for payment
  def mail_on_order_due_date() do
    invoices =
      Order.all_invoice()
      |> Enum.filter(fn invoice ->
        due_date = Mailer.naive_date(invoice.due_date)
        Date.diff(due_date, now()) == 0
      end)

    Enum.map(invoices, fn invoice ->
      invoice = Order.preload_invoice(invoice)
      sale = Order.preload_order(invoice).sale

      %{
        company_id: invoice.sale.company_id,
        actor_id: invoice.sale.user_id,
        message: "Invoice with reference id #{invoice.ref_id} is due for payment today"
      }
      |> Notifications.create_notification({:invoice, invoice}, :due)

      M2C.send_reminder(sale)
      YC2C.send_invoice_due_notification(sale)
    end)
  end

  # sends emails 3 days before the orders are due for payment
  def mail_before_order_due_date() do
    Order.all_invoice()
    |> Enum.filter(fn invoice ->
      due_date = Mailer.naive_date(invoice.due_date)
      Date.diff(due_date, now()) == 3
    end)
    |> Enum.map(fn invoice ->
      Order.preload_order(invoice).sale
      |> M2C.send_reminder()
    end)
  end

  # sends emails 3 days after the orders are due for payment
  def mail_after_order_due_date() do
    Order.all_invoice()
    |> Enum.filter(fn invoice ->
      due_date = Mailer.naive_date(invoice.due_date)
      Date.diff(now(), due_date) == 3
    end)
    |> Enum.map(fn invoice ->
      Order.preload_order(invoice).sale
      |> M2C.send_early_due_mail()
    end)
  end

  # sends emails 7 days after the orders are due for payment
  def mail_after_order_overdue() do
    Order.all_invoice()
    |> Enum.filter(fn invoice ->
      due_date = Mailer.naive_date(invoice.due_date)
      Date.diff(now(), due_date) == 7
    end)
    |> Enum.map(fn invoice ->
      Order.preload_order(invoice).sale
      |> M2C.send_late_overdue_mail()
    end)
  end

  # create activities when order is due
  def create_activity_when_order_due() do
    Order.all_invoice()
    |> Enum.filter(fn invoice ->
      {:ok, due_date} = Timex.parse(invoice.due_date, "{YYYY}-{0M}-{D}")
      Date.diff(due_date, now()) == 0
    end)
    |> create_mul_activities()
  end

  def send_notifications() do
    Notifications.get_unsent_notifications()
    |> Enum.map(fn notification ->
      send_user_notification(notification)
    end)
  end

  ### Private Functions
  defp create_mul_activities(invoices) do
    Enum.map(invoices, fn invoice ->
      invoice = Order.preload_invoice(invoice)

      Order.create_activity(
        "due_payment",
        "#{Order.calc_pay_outstanding(invoice.sale)}",
        invoice.id,
        invoice.sale.contact_id,
        invoice.company_id
      )
    end)
  end

  defp send_user_notification(notification) do
    with %MobileDevice{} = mobile_device <-
           Notifications.get_last_updated_mobile_device(notification.actor_id),
         data <- construct_notification_data(notification),
         {:ok, :success, %{"id" => _id}} = response <-
           send_notification_to_mobile_device(mobile_device.device_token, data, notification),
         :ok <- Logger.info("OneSignal response: #{inspect(response)}") do
      notification
      |> Notifications.update_notification(%{delivery_status: "sent"})
    else
      nil ->
        notification

      {:ok, _status, _body} = response ->
        Logger.info("OneSignal response: #{inspect(response)}")
        notification

      _reponse = response ->
        Logger.info "FCM response: #{inspect(response)}"
        notification
    end
  end

  defp construct_notification_data(notification) do
    notification
    |> Map.from_struct()
    |> Map.drop([:__meta__, :actor, :company, :mobile_devices])
    |> Map.put(:notification_items, transform_notification_items(notification))
  end

  defp send_notification_to_mobile_device(device_token, data, notification) do
    url = "https://onesignal.com/api/v1/notifications"

    body =
      gen_notification_req_params(device_token, data, notification)
      |> Base.encode()

    headers = [{"Authorization", System.get_env("ONESIGNAL_API_KEY")}]

    Base.request(:post, url, body, headers)
    |> Base.process_response()
  end

  defp transform_notification_items(%{notification_items: []}) do
    []
  end

  defp transform_notification_items(%{notification_items: items}) do
    Enum.map(items, fn item ->
      Map.from_struct(item)
      |> Map.drop([:__meta__, :notification])
    end)
  end

  defp gen_notification_req_params(device_token, data, notification) do
    %{
      "app_id" => System.get_env("ONESIGNAL_APP_ID"),
      "include_android_reg_ids" => [device_token],
      "data" => data,
      "contents" => %{"en" => notification.message},
      "headings" => %{"en" => gen_notification_heading(notification)}
    }
  end

  defp gen_notification_heading(notification) do
    (String.capitalize(notification.element) <> " " <> notification.action_type)
    |> String.replace("_", " ")
  end

  defp now() do
    DateTime.to_naive(Timex.now())
  end
end
