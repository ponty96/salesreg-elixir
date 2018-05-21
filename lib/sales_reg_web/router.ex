defmodule SalesRegWeb.Router do
  use SalesRegWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :graphql do
    plug SalesReg.AuthPipeline
    plug SalesReg.Context
  end

  scope "/api", SalesRegWeb do
    pipe_through(:api)
  end

  #graphiql endpoint
end
