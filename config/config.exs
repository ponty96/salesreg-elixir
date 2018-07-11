# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :sales_reg, SalesRegWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "VQaqMBckFxan8bqvUksPqhTZvKJDSgCVvQ9nblU+4zDlW7LcnnmI8JloECqXM8sW",
  render_errors: [view: SalesRegWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: SalesReg.PubSub, adapter: Phoenix.PubSub.PG2]

# General application configuration
config :sales_reg,
  ecto_repos: [SalesReg.Repo],
  generators: [binary_id: true]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :sales_reg, SalesRegWeb.TokenImpl,
  issuer: "sales_reg",
  secret_key: "Q/pRXuJQoZblGk4AIOHhMX0AkzuUpBS91hQVlO06PqrtRd/iAobc3CdBkMPDVYgc"

config :guardian, Guardian.DB,
  repo: SalesReg.Repo,
  # default
  schema_name: "guardian_tokens",
  # default: 60 minutes
  sweep_interval: 60,
  ttl: {30, :days}

###############################################################
### AWS (image upload functionality) config
###############################################################

# config :ex_aws,
#   access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
#   secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role]

# config :ex_aws, :hackney_opts,
#   follow_redirect: true,
#   recv_timeout: 30_000

# config :ex_aws,
#   region: "us-west-2"

# config :ex_aws, :retries,
#   max_attempts: 10,
#   base_backoff_in_ms: 10,
#   max_backoff_in_ms: 10_000

##############################################################
### Ends here
##############################################################

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
