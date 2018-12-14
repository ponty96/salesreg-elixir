defmodule SalesReg.Email do
	use SalesRegWeb, :context
	import Bamboo.Email

	def send_email(sale, type) do
		sale = Order.preload_sale(sale)
		
		sale
		|> Theme.get_email_template_by_type(type)
		|> transform_template(sale)
		|> construct_email(sale, type)
		|> send_email()
	end

	def send_email(email_params) do
		new_email(
			from:  email_params.from,
      to: email_params.to,
      subject: email_params.subject,
			html_body: email_params.html_body,
			text_body: email_params.text_body
		)
	end

	defp transform_template(template, sale) do
		# DO SOMETHING
	end

	defp construct_email(html_body, sale, type) do
		%{
			to: sale.company.contact_email,
			from: "support@yipcart.com",
			subject: gen_sub(type),
			html_body: html_body,
		}
	end

	defp gen_sub(type) do
		case type do
			"invoice_pre_due_date" ->
				:ok
			"invoice_on_due_date" ->
				:ok
			"invoice_post_due_date" ->
				:ok
			"invoice_on_order" ->
				:ok
			"order_receipt" ->
				:ok
			_ -> 
				:ok
		end
	end
end
