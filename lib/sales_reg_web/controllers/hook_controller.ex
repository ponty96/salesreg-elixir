defmodule SalesRegWeb.HookController do
	use SalesRegWeb, :controller
	alias SalesReg.WebhookHandler

	def hook(conn, %{"event" => "charge.success"} = params) do
		WebhookHandler.insert_receipt(params)
		put_status(conn, 200)
		|> json("Successful")
	end
end