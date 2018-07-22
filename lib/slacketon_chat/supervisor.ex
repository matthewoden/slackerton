defmodule SlackertonChat.Supervisor do
  
  use Supervisor
  alias SlackertonChat.{WeatherResolver, Robot}

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    children = [
      {Lex, lex_config()},
      # TODO: rig up multiple slacks at once
      robot({"dnd", System.get_env("SLACKERTON_DND_SLACK_TOKEN") }),
      scheduled("weather_alerts", { WeatherResolver, :broadcast_alert, []}, "*/5 * * * *")
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def lex_config() do
    %{
      aws_access_key_id: System.get_env("SLACKERTON_AWS_ACCESS_KEY_ID"),
      aws_secret_access_key: System.get_env("SLACKERTON_AWS_SECRET_ACCESS_KEY"),
      http_adapter: Lex.Http.Hackney,
      json_parser: Lex.Json.Jason
    }
  end

  def robot({ team, token }) do
    %{
      id: team,
      start: {Hedwig, :start_robot, [ 
        Robot,  [ team: team, token: token ]
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