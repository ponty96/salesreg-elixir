defmodule SalesReg.Tasks do
  use SalesRegWeb, :context
  alias SalesReg.Mailer.YipcartToCustomers, as: YC2C
  alias SalesReg.Mailer.MerchantsToCustomers, as: M2C
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
        element_data: "Invoice with reference id #{invoice.ref_id} is due for payment today"
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
        %Pigeon.FCM.Notification{status: :success} = fcm_response <-
          send_notification_to_mobile_device(mobile_device.device_token, data),
        :ok <- Logger.info("FCM response: #{inspect(fcm_response)}") do
      
      notification
      |> Notifications.update_notification(%{delivery_status: "sent"})
    else
      nil ->
        notification

      %Pigeon.FCM.Notification{status: _status} = fcm_response ->
        Logger.info("FCM response: #{inspect(fcm_response)}")
        notification

      _ ->
        notification
    end
  end

  defp construct_notification_data(notification) do
    notification
    |> Map.from_struct()
    |> Map.drop([:__meta__, :actor, :company, :mobile_devices])
    |> Map.put(:notification_items, transform_notification_items(notification))
  end

  defp send_notification_to_mobile_device(device_token, data) do
    device_token
    |> Pigeon.FCM.Notification.new(%{}, data)
    |> Pigeon.FCM.push()
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

  defp now() do
    DateTime.to_naive(Timex.now())
  end
end
