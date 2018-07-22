use Mix.Config

config :slackerton, SlackertonChat.Robot,
  adapter: Hedwig.Adapters.Slack

config :slackerton, Slackerton.Github.Api,
  http_adapter: HttpBuilder.Adapters.HTTPoison,
  json_parser: Jason,
  repo: "matthewoden/slackerton",
  api_key: System.get_env("SLACKERTON_GITHUB_TOKEN")

config :slackerton, SlackertonWeb.Endpoint,
  load_from_system_env: true,
  url: [scheme: "https", host: "dnd-slackbot.herokuapp.com", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json"
  secret_key_base: Map.fetch!(System.get_env(), "SLACKERTON_SECRET_KEY_BASE")