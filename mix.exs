defmodule SalesReg.Mixfile do
  use Mix.Project

  def project do
    [
      app: :sales_reg,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {SalesReg.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools,
        :comeonin,
        :guardian,
        :ex_aws,
        :ex_aws_s3,
        :uuid,
        :hackney,
        :pdf_generator,
        :ueberauth,
        :ueberauth_identity,
        :bamboo,
        :sentry
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.2"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_ecto, "~> 4.0"},
      {:postgrex, ">= 0.0.0"},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:comeonin, "~> 4.0"},
      {:guardian, "~> 1.0"},
      {:bcrypt_elixir, "~> 1.0"},
      {:absinthe, "~> 1.5.0-alpha.0", override: true},
      # {:absinthe_ecto, "~> 0.1.3"},
      {:absinthe_plug, "~> 1.4.5"},
      {:absinthe_relay, github: "absinthe-graphql/absinthe_relay"},
      {:dataloader, "~> 1.0.0"},
      {:faker, "~> 0.10"},
      {:guardian_db, github: "ueberauth/guardian_db"},
      {:ex_aws, "~> 2.0"},
      {:ex_aws_s3, "~> 2.0"},
      {:uuid, "~> 1.1"},
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.6"},
      {:machinery, github: "ponty96/machinery", branch: "bump_ecto_version"},
      {:ecto_sql, "~> 3.0"},
      {:jason, "~> 1.1"},
      {:arc, "~> 0.11.0"},
      {:pdf_generator, "~> 0.4.0"},
      {:plug_cowboy, "~> 1.0"},
      {:ueberauth, "~> 0.5"},
      {:ueberauth_identity, "~> 0.2"},
      {:bamboo, "~> 1.1"},
      {:plug_attack, "~> 0.3.0"},
      {:remote_ip, "~> 0.1.0"},
      {:quantum, "~> 2.3"},
      {:timex, "~> 3.0"},
      {:sentry, "~> 6.4"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      sentry_recompile: ["deps.compile sentry --force", "compile"]
    ]
  end
end
