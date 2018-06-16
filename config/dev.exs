use Mix.Config

config :slackerton, Slackerton.Robot,
  adapter: Hedwig.Adapters.Slack
  #adapter: Hedwig.Adapters.Console
