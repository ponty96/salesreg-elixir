defmodule SalesReg.Email do
	use SalesRegWeb, :context
	import Bamboo.Email

	def send_email(company_id, type) do
		send_email(company_id, type, %Sale{})
	end

	def send_email(company_id, type, sale) do
		sale = Order.preload_order(sale)
		company = 
			sale.company || 
			Business.get_company(company_id)
		
		company_id
		|> Theme.get_email_template_by_type(type)
		|> transform_template(sale)
		|> construct_email(company.contact_email, type)
		|> send_email()
		|> Mailer.deliver_later()
	end

	def send_email(email_params) do
		new_email(
			from:  email_params.from,
      to: email_params.to,
      subject: email_params.subject,
			html_body: email_params.html_body,
		)
		|> Mailer.deliver_later()
	end

	defp transform_template(template, sale) do
		EEx.eval_string(template.body, sale: sale)
	end

	defp construct_email(html_body, receipient, type) do
		%{
			to: receipient,
			from: "opeyemi.badmos@yipcart.com",
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
