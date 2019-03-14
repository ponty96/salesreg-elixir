use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :sales_reg, SalesRegWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :sales_reg, SalesReg.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "sales_reg_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :sales_reg, SalesRegWeb.Services.Heroku,
  base_domain: "yipcart-test-domain.com",
  app_id_or_name: "yipcart-id",
  api_base_url: "https://api.heroku.com/apps/test",
  default_header: [
    {"Content-Type", "application/json"},
    {"Accept", "application/vnd.heroku+json; version=3"},
    {"Authorization", "Bearer thisisarandomtokenfortest"}
  ]