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
    plug(:accepts, ["json"])
  end

  if Mix.env() == :dev do
    forward("/sent_emails", Bamboo.SentEmailViewerPlug)
  end

  pipeline :hook do
    plug(SalesRegWeb.Plug.ValidateFlutterRequest)
  end

  scope "/api/flutterwave", SalesRegWeb do
    pipe_through([:api, :hook])

    post("/webhooks/payment", HookController, :hook)
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

  scope "/graphiql" do
    if Mix.env() == :dev or Mix.env() == :test do
      pipe_through([:api, :graphql])
      forward("/", Absinthe.Plug.GraphiQL, schema: SalesRegWeb.GraphQL.Schemas)
    end
  end

  scope "/", SalesRegWeb do
    pipe_through(:browser)
    # get("/:business_slug/c/:category_slug", ForwardController, :forward_category)
    get("/:business_slug/in/:invoice_id", ForwardController, :forward_invoice)
    get("/:business_slug/s/:sale_id", ForwardController, :forward_sale)
    get("/:business_slug/r/:receipt_id", ForwardController, :forward_receipt)
    get("/:business_slug/p/:product_slug", ForwardController, :forward_product)
    get("/:business_slug", ForwardController, :forward_business)
  end

  # graphiql endpoint
end
