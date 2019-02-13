defmodule SalesReg.Tasks do
  use SalesRegWeb, :context
  alias SalesReg.Mailer.YipcartToCustomers, as: YC2C
  alias SalesReg.Mailer.MerchantsToCustomers, as: M2C

  # sends emails on the day orders are due for payment
  def mail_on_order_due_date() do
    invoices =
      Order.all_invoice()
      |> Enum.filter(fn invoice ->
        due_date = Mailer.naive_date(invoice.due_date)
        Date.diff(due_date, now()) == 0
      end)

    Enum.map(invoices, fn(invoice) ->
      Order.preload_order(invoice).sale
      |> M2C.send_reminder()
    end)
    
    Enum.map(invoices, fn(invoice) ->
      Order.preload_order(invoice).sale
      |> YC2C.send_invoice_due_notification()
    end)
  end

  # sends emails 3 days before the orders are due for payment
  def mail_before_order_due_date() do
    Order.all_invoice()
    |> Enum.filter(fn invoice ->
      due_date = Mailer.naive_date(invoice.due_date)
      Date.diff(due_date, now()) == 3
    end)
    |> Enum.map(fn(invoice) ->
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
    |> Enum.map(fn(invoice) ->
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
    |> Enum.map(fn(invoice) ->
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

  defp now() do
    DateTime.to_naive(Timex.now())
  end
end
