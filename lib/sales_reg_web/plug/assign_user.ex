defmodule SalesRegWeb.Plug.AssignUser do
	use SalesRegWeb, :context
	
	import Comeonin.Bcrypt
	import Plug.Conn

	def init(opts) do
		opts
	end
	
	def call(conn, repo) do
		user_id = get_session(conn, :user_id)
		user = user_id && Accounts.get_user(user_id)
		assign(conn, :current_user, user)
	end
end

