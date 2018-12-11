defmodule SalesRegWeb.Router do
  use SalesRegWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  # Whitelist IPs simply by adding it to the list below
  pipeline :api do
    plug RemoteIp
    plug SalesRegWeb.PlugAttack
    plug(:accepts, ["json"])
  end

  scope "/api/paystack", SalesRegWeb do
    pipe_through(:api)

    post("/webhooks", HookController, :hook)
  end

  pipeline :graphql do
    plug(SalesRegWeb.AuthPipeline)
    plug(SalesRegWeb.AbsintheContext)
  end

  scope "/api" do
    pipe_through(:graphql)

    forward("/", Absinthe.Plug, schema: SalesRegWeb.GraphQL.Schemas)
  end

  pipe_through([:api, :graphql])
  forward("/graphiql", Absinthe.Plug.GraphiQL, schema: SalesRegWeb.GraphQL.Schemas)
  
  # graphiql endpoint
end
