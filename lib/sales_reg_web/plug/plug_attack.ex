defmodule SalesRegWeb.PlugAttack do
  @moduledoc """
  Plug Attack Module
  """
  import Plug.Conn
  use PlugAttack

  rule "allow local", conn do
    allow(conn.remote_ip == {127, 0, 0, 1})
  end
end
