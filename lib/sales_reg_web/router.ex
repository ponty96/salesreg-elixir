defmodule SalesRegWeb.Router do
  use SalesRegWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :graphql do
    plug(SalesRegWeb.AuthPipeline)
    plug(SalesRegWeb.Context)
  end

  scope "/api" do
    pipe_through(:graphql)

    forward("/", Absinthe.Plug, schema: SalesRegWeb.Schemas)
  end

  if Mix.env() == :dev do
    pipe_through([:api, :graphql])
    forward("/graphiql", Absinthe.Plug.GraphiQL, schema: SalesRegWeb.Schemas)
  end

  # graphiql endpoint
end
