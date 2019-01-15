defmodule SalesReg.Tasks do
  use SalesRegWeb, :context

	# sends emails on the day orders are due for payment
	def mail_on_order_due_date() do
		Order.all_invoice()
		|> Enum.filter(fn invoice ->
				{:ok, due_date} = Timex.parse(invoice.due_date, "{YYYY}-{0M}-{D}")
				Date.diff(due_date, now()) == 0
		end)
		|> send_mul_email("yc_email_reminder")
	end

	# sends emails 3 days before the orders are due for payment
	def mail_before_order_due_date() do
		Order.all_invoice()
		|> Enum.filter(fn invoice ->
				{:ok, due_date} = Timex.parse(invoice.due_date, "{YYYY}-{0M}-{D}") 
				Date.diff(due_date,  now()) == 3
		end)
		|> send_mul_email("yc_email_reminder")
	end

	# sends emails 3 days after the orders are due for payment
	def mail_after_order_due_date() do
		Order.all_invoice()
		|> Enum.filter(fn invoice ->
				{:ok, due_date} = Timex.parse(invoice.due_date, "{YYYY}-{0M}-{D}") 
				Date.diff(now(), due_date) == 3
		end)
		|> send_mul_email("yc_email_early_due")
	end

	# sends emails 7 days after the orders are due for payment
	def mail_after_order_overdue() do
		Order.all_invoice()
		|> Enum.filter(fn invoice ->
				{:ok, due_date} = Timex.parse(invoice.due_date, "{YYYY}-{0M}-{D}") 
				Date.diff(now(), due_date) == 7
		end)
		|> send_mul_email("yc_email_late_overdue")
	end

  def create_activity_when_order_due() do
    Order.all_invoice()
    |> Enum.filter(fn invoice ->
      {:ok, due_date} = Timex.parse(invoice.due_date, "{YYYY}-{0M}-{D}")
      Date.diff(due_date, now()) == 0
    end)
    |> create_mul_activities()
  end
  
	### Private Functions
	defp send_mul_email(invoices, type) do
		Enum.map(invoices, fn(invoice) ->
				invoice = Order.preload_invoice(invoice)
				Email.send_email(invoice.sale, type)
		end)
	end

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
