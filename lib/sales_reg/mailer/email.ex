defmodule SalesReg.Email do
	use SalesRegWeb, :context
	import Bamboo.Email

	def send_email(%Company{} = company, type, binary) do
		binary
		|> transform_template(company)
		|> construct_email(company, type)
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
		new_email(
			from:  email_params.from,
      to: email_params.to,
      subject: email_params.subject,
			html_body: email_params.html_body
		)
		|> Mailer.deliver_later()
	end

	defp transform_template(template, %Sale{} = sale) do
		EEx.eval_string(template.body, sale: sale)
	end

	defp transform_template(binary, %Company{} = company) do
		EEx.eval_string(binary, company: company)
	end
	
	defp construct_email(html_body, %Company{} = company, type) do
		%{
			to: company.contact_email,
			from: "opeyemi.badmos@yipcart.com",
			subject: gen_sub(type),
			html_body: html_body,
		}
	end

	defp construct_email(html_body, %Sale{} = sale, type) do
		%{
			to: sale.contact.email,
			from: sale.company.contact_email, 
			subject: gen_sub(type),
			html_body: html_body,
		}
	end

	defp gen_sub(type) do
		case type do
			"yc_email_before_due" ->
				"Email Before Due Date"
			
			"yc_email_early_due" ->
				"Email Early Due Date"
			
			"yc_email_late_overdue" ->
				"Email Received Overdue"
			
			"yc_email_received_order" ->
				"Email Received Order"
			
			"yc_email_reminder" ->
				"Email Reminder"
		
			"yc_email_restock" -> 
				"Email Restock"
	
			"yc_email_welcome_to_yc" -> 
				"Email Welcome To YC"

			"yc_payment_received" ->
				"Payment Received"

			_ -> "No Subject"
		end
	end
end
