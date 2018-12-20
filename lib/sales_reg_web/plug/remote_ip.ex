defmodule MyApp do
  use Plug.Builder

  plug(RemoteIp)
end
