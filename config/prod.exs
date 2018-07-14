use Mix.Config

config :slackerton, Slackerton.Robot,
  adapter: Hedwig.Adapters.Slack

config :slackerton, Slackerton.Github.Api,
  http_adapter: HttpBuilder.Adapters.HTTPoison,
  json_parser: Jason,
  repo: "matthewoden/slackerton",
  api_key: System.get_env("SLACKERTON_GITHUB_TOKEN")