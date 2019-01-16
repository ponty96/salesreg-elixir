defmodule SalesRegWeb.Router do
  use SalesRegWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(SalesRegWeb.Plug.AssignUser)
  end

  # RemoteIp should always be the first in the pipeline
  pipeline :api do
    plug(RemoteIp)
    plug(SalesRegWeb.PlugAttack)
    plug(:accepts, ["json"])
  end

  scope "/api/paystack", SalesRegWeb do
    pipe_through(:api)

    post("/webhooks", HookController, :hook)
  end

  scope "/", SalesRegWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/company", ThemeController, :index)
    resources("/users", UserController, only: [:new, :create])
    resources("/companies", CompanyController, only: [:new, :create])
  end

  scope "/auth", SalesRegWeb do
    pipe_through(:browser)

    get("/identity", SessionController, :request)
    get("/identity/callback", SessionController, :callback)
    post("/identity/callback", SessionController, :callback)
    delete("/logout", SessionController, :delete)
  end

  pipeline :graphql do
    plug(SalesRegWeb.AuthPipeline)
    plug(SalesRegWeb.AbsintheContext)
  end

  scope "/api" do
    pipe_through(:graphql)

    forward("/", Absinthe.Plug, schema: SalesRegWeb.GraphQL.Schemas)
  end

  if Mix.env() == :dev or Mix.env() == :test do
    pipe_through([:api, :graphql])
    forward("/graphiql", Absinthe.Plug.GraphiQL, schema: SalesRegWeb.GraphQL.Schemas)
  end

  # graphiql endpoint
end
