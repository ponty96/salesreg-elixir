# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :sales_reg,
  ecto_repos: [SalesReg.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :sales_reg, SalesRegWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "VQaqMBckFxan8bqvUksPqhTZvKJDSgCVvQ9nblU+4zDlW7LcnnmI8JloECqXM8sW",
  render_errors: [view: SalesRegWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: SalesReg.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :sales_reg, SalesRegWeb.Guardian,
    issuer: "SalesRegWeb",
    secret_key: "Q/pRXuJQoZblGk4AIOHhMX0AkzuUpBS91hQVlO06PqrtRd/iAobc3CdBkMPDVYgc"
  

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
