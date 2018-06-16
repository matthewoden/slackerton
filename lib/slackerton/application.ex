defmodule Slackerton.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised

    slackerton_config = %{
      aws_access_key_id: System.get_env("SLACKERTON_AWS_ACCESS_KEY_ID"),
      aws_secret_access_key: System.get_env("SLACKERTON_AWS_SECRET_ACCESS_KEY"),
      http_adapter: Lex.Http.Hackney,
      json_parser: Lex.Json.Jason,
    }


    children = [
      {Slackerton.Robot, []},
      {Slackerton.Brain, []},
      {Lex, slackerton_config}
    ]

    opts = [strategy: :one_for_one, name: Slackerton.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
