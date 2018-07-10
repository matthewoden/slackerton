defmodule Slackerton.Application do
  @moduledoc false

  use Application
  import Supervisor.Spec, warn: false
  alias Slackerton.{Cache, User, Weather, Trivia}

  def start(_type, _args) do

    lex_config = %{
      aws_access_key_id: System.get_env("SLACKERTON_AWS_ACCESS_KEY_ID"),
      aws_secret_access_key: System.get_env("SLACKERTON_AWS_SECRET_ACCESS_KEY"),
      http_adapter: Lex.Http.Hackney,
      json_parser: Lex.Json.Jason,
    }

    children = [
      supervisor(Cache, []),
      worker(Cache.Warmer, [], [restart: :temporary]),
      {Trivia.Store, []},
      {Lex, lex_config},
      robot({"dnd", System.get_env("SLACKERTON_DND_SLACK_TOKEN") }),
      # scheduled("weather_alerts", { Weather, :severe_weather, ["bot-testing"]}, "*/5 * * * *")
    ]

    opts = [strategy: :one_for_one, name: Slackerton.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # worker wrappers
  def robot({ team, token }) do
    %{
      id: team,
      start: {Hedwig, :start_robot, [ 
        Slackerton.Robot,  [ team: team, token: token ]
      ]}
    }
  end

  def scheduled(id, {mod, fun, args}, cron) do
    %{ 
      id: id, 
      start: {SchedEx, :run_every, [
        mod, fun, args, cron
      ]} 
    }
  end
end
