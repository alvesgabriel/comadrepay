# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :comadrepay,
  ecto_repos: [Comadrepay.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :comadrepay, ComadrepayWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "P9qhIyDvZA4kqPpuorJoXGxFDf19xvhLqlmJ0ONlpifeYSa2lIh8AoC/FXVz7SGj",
  render_errors: [view: ComadrepayWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Comadrepay.PubSub,
  live_view: [signing_salt: "4mbefctj"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :comadrepay, Comadrepay.Auth.Guardian,
  issuer: "Comadrepay",
  secret_key:
    System.get_env(
      "GUARDIAN_SECRET",
      "Secret key. You can use `mix guardian.gen.secret` to get one"
    )

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
