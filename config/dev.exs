use Mix.Config

config :slackerton, SlackertonChat.Robot,
  adapter: Hedwig.Adapters.Slack
  #adapter: Hedwig.Adapters.Console

