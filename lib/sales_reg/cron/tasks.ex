defmodule SalesReg.Tasks do
	use SalesRegWeb, :context

	def mail_on_order_due_date() do
		Order.all_invoice()
		|> Enum.filter(fn invoice ->
				{:ok, due_date} = Timex.parse(invoice.due_date, "{YYYY}-{0M}-{D}")
				Date.diff(due_date, now()) == 0
		end)
		|> send_mul_email("yc_email_early_due")
	end

	def mail_before_order_due_date() do
		Order.all_invoice()
		|> Enum.filter(fn invoice ->
				{:ok, due_date} = Timex.parse(invoice.due_date, "{YYYY}-{0M}-{D}") 
				Date.diff(due_date,  now()) == 3
		end)
		|> send_mul_email("yc_email_before_due")
	end

	def mail_after_order_overdue() do
		Order.all_invoice()
		|> Enum.filter(fn invoice ->
				{:ok, due_date} = Timex.parse(invoice.due_date, "{YYYY}-{0M}-{D}") 
				Date.diff(now, due_date) == 7
		end)
		|> send_mul_email("yc_email_late_overdue")
	end

	### Private Functions
	defp send_mul_email(invoices, type) do
		Enum.map(invoices, fn(invoice) ->
				invoice = Order.preload_invoice(invoice)
				Email.send_email(type, invoice.sale)
		end)
	end

	defp now() do
		DateTime.to_naive(Timex.now())
	end
end