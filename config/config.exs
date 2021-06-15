# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :cache_cow,
  ecto_repos: [CacheCow.Repo]

# Configures the endpoint
config :cache_cow, CacheCowWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ffDsPBLa70+JXur2uoWCQd71IU5uGu7NNPppB4l3TOXf/qfw/Z38Iji9hXJgIpz0",
  render_errors: [view: CacheCowWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: CacheCow.PubSub,
  live_view: [signing_salt: "jj/d+FVf"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
