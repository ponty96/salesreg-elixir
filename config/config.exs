# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :sales_reg, SalesRegWeb.Endpoint,
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

config :logger,
  backends: [:console],
  level: :debug,
  format: "\n$time $metadata[$level] $levelpad$message\n",
  metadata: :all

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

# config :arc,
#   storage: Arc.Storage.S3, # or Arc.Storage.Local
#   bucket: System.get_env("AWS_S3_BUCKET")

# config :ex_aws,
#   access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
#   secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role],
#   scheme: "https://",
#   host: %{"nyc3" => System.get_env("AWS_HOST")},
#   region: "nyc3"

config :arc,
  storage: Arc.Storage.S3,
  bucket: System.get_env("AWS_S3_BUCKET"),
  virtual_host: false,
  asset_host:
    "https://yipcartimages.nyc3.digitaloceanspaces.com/#{System.get_env("AWS_S3_BUCKET")}"

config :ex_aws,
  access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
  s3: [
    scheme: "https://",
    host: System.get_env("AWS_HOST"),
    region: "nyc3"
  ]

config :ex_aws, debug_requests: true

# config :plug, :statuses, %{
#   210 => "Image not uploaded",
#   209 => "Image successfully uploaded"
# }

config :pdf_generator,
  wkhtml_path: "/usr/local/bin/wkhtmltopdf",
  pdftk_path: "/path/to/pdftk"

config :ueberauth, Ueberauth,
  providers: [
    identity:
      {Ueberauth.Strategy.Identity,
       [
         callback_methods: ["POST"],
         uid_field: :email,
         nickname_field: :email,
         request_path: "/auth/identity",
         callback_path: "/auth/identity/callback"
       ]}
  ]

config :sales_reg, SalesReg.Mailer,
  adapter: Bamboo.SendGridAdapter,
  api_key: "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"

config :sales_reg, SalesReg.Scheduler,
  jobs: [
    mail_on_order_due_date: [
      schedule: "@daily",
      task: {SalesReg.Tasks, :mail_on_order_due_date, []}
    ],
    mail_before_order_due_date: [
      schedule: "@daily",
      task: {SalesReg.Tasks, :mail_before_order_due_date, []}
    ],
    mail_after_order_due_date: [
      schedule: "@daily",
      task: {SalesReg.Tasks, :mail_after_order_due_date, []}
    ],
    mail_after_order_overdue: [
      schedule: "@daily",
      task: {SalesReg.Tasks, :mail_after_order_overdue, []}
    ],
    create_activity_when_order_due: [
      schedule: "@daily",
      task: {SalesReg.Tasks, :create_activity_when_order_due, []}
    ]
  ]

  config :heroku,
    base_domain: System.get_env("BASE_DOMAIN"),
    app_id_or_name: System.get_env("APP_ID_OR_NAME"),
    api_base_url: "https://api.heroku.com/apps/",
    default_header: [
      {"Content-Type", "application/json"},
      {"Accept", "application/vnd.heroku+json; version=3"},
      {"Authorization", "Bearer #{System.get_env("AUTH_TOKEN")}"}
    ]

  config :cloudfare,
    zone_id: System.get_env("ZONE_ID"),
    api_base_url: "https://api.cloudflare.com/client/v4/zones/",
    default_header: [
      {"X-Auth-Key", "#{System.get_env("X_AUTH_KEY")}"},
      {"Content-Type", "application/json"},
      {"X-Auth-Email", "#{System.get_env("X_AUTH_EMAIL")}"}
    ]
    

###############################################################
### AWS (image upload functionality) config
###############################################################

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
