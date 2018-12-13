defmodule SalesRegWeb.Router do
  use SalesRegWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug SalesRegWeb.Plug.AssignUser
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api/image" do
    pipe_through(:api)

    post("/upload", SalesRegWeb.ImageController, :upload_image)
  end

  scope "/", SalesRegWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
    resources("/users", UserController, only: [:new, :create])
    resources("/companies", CompanyController, only: [:new, :create])
  end

  scope "/auth", SalesRegWeb do
    pipe_through :browser

    get "/identity", SessionController, :request
    get "/identity/callback", SessionController, :callback
    post "/identity/callback", SessionController, :callback
    delete "/logout", SessionController, :delete
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
