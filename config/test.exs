use Mix.Config

config :slackerton, Slackerton.Robot,
  adapter: Hedwig.Adapters.Console

config :slackerton, Slackerton.Wordnik.Api,
  http_adapter: Slackerton.Adapters.WordnikTest,
  json_parser: Jason,
  wordnik_key: System.get_env("SLACKERTON_WORDNICK_TOKEN")