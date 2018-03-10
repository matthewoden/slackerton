# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :slackerton, Slackerton.Robot,
  name: "slackerton",
  aka: "/",
  token: System.get_env("MATHBEAR_SLACK_TOKEN"),
  rooms: [],
  responders: [
    {Hedwig.Responders.Help, []},
    {Slackerton.Responders.Mathbear, []},
    {Slackerton.Responders.Slap, []},
    {Slackerton.Responders.Search, []},
    {Slackerton.Responders.Rotator, []},
    {Slackerton.Responders.NaturalLanguage, []},
    {Slackerton.Responders.Trivia, []}
  ]

config :slackerton, 
  http_adapter: HttpBuilder.Adapters.HTTPoison,
  json_decoder: Jason,
  wolfram_key: System.get_env("SLACKERTON_WOLFRAM_API_TOKEN")

config :logger,
  backends: [:console],
  compile_time_purge_level: :info

import_config "#{Mix.env}.exs"