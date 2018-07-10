# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :slackerton, Slackerton.Cache,
  adapter: Nebulex.Adapters.Local,
  gc_interval: 86_400 # 24 hrs

config :slackerton, Slackerton.Robot,
  name: "slackerton",
  aka: "/",
  token: System.get_env("MATHBEAR_SLACK_TOKEN"),
  rooms: [],
  log_level: :debug,
  responders: [
    {Hedwig.Responders.Help, []},
    {Slackerton.Responders.DadJokes, []},
    {Slackerton.Responders.Trivia, []},
    {Slackerton.Responders.Calculate, []},
    {Slackerton.Responders.NaturalLanguage, []},
  ],
  plugs: [
    {Slackerton.Auth, []},
    {Slackerton.Responders.NaturalLanguage, []}
  ]

config :slackerton, 
  http_adapter: HttpBuilder.Adapters.HTTPoison,
  json_parser: Jason,
  user_agent: System.get_env("SLACKERTON_USER_AGENT"),
  wolfram_key: System.get_env("SLACKERTON_WOLFRAM_API_TOKEN")

config :slackerton, Lex,
  region: "us-east-1",
  bot_alias: "dev",
  bot_name: "Slackerton",
  aws_access_key_id: System.get_env("SLACKERTON_AWS_ACCESS_KEY_ID"),
  aws_secret_access_key: System.get_env("SLACKERTON_AWS_SECRET_ACCESS_KEY")

config :ex_aws,
  json_codec: Jason,
  access_key_id: System.get_env("SLACKERTON_AWS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("SLACKERTON_AWS_SECRET_ACCESS_KEY")

config :logger,
  backends: [:console],
  level: :debug,
  compile_time_purge_level: :debug

config :slackerton, Slackerton.Wordnik.Api,
  http_adapter: HttpBuilder.Adapters.HTTPoison,
  json_parser: Jason,
  wordnik_key: System.get_env("SLACKERTON_WORDNICK_TOKEN")

config :slackerton, Slackerton.News.Api,
  http_adapter: HttpBuilder.Adapters.HTTPoison,
  json_parser: Jason,
  api_key: System.get_env("SLACKERTON_NEWS_API")

import_config "#{Mix.env}.exs"