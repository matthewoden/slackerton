# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :slackerton, Slackerton.Robot,
  name: "slackerton",
  aka: "/",
  token: System.get_env("MATHBEAR_SLACK_TOKEN"),
  rooms: [],
  log_level: :debug,
  responders: [
    {Hedwig.Responders.Help, []},
    {Slackerton.Responders.Mathbear, []},
    {Slackerton.Responders.Slap, []},
    {Slackerton.Responders.Search, []},
    {Slackerton.Responders.Rotator, []},
    {Slackerton.Responders.NaturalLanguage, []},
    {Slackerton.Responders.DadJokes, []},
    {Slackerton.Responders.Trivia, []}
  ]

config :slackerton, 
  http_adapter: HttpBuilder.Adapters.HTTPoison,
  json_parser: Jason,
  wolfram_key: System.get_env("SLACKERTON_WOLFRAM_API_TOKEN")

config :slackerton, Lex,
  region: "us-east-1",
  bot_alias: "dev",
  bot_name: "Slackerton",
  aws_access_key_id: System.get_env("SLACKERTON_AWS_ACCESS_KEY_ID"),
  aws_secret_access_key: System.get_env("SLACKERTON_AWS_SECRET_ACCESS_KEY")

config :logger,
  backends: [:console],
  level: :debug,
  compile_time_purge_level: :debug

import_config "#{Mix.env}.exs"