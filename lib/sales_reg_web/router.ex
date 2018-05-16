defmodule SalesRegWeb.Router do
  use SalesRegWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SalesRegWeb do
    pipe_through :api
  end
end
