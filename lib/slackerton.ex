defmodule Slackerton do
  @moduledoc false

  use Application
  import Supervisor.Spec, warn: false


  def start(_type, _args) do

    children = [
      {Slackerton.Supervisor, []},
      {SlackertonChat.Supervisor, []},
      supervisor(SlackertonWeb.Endpoint, [])
    ]

    opts = [strategy: :one_for_one, name: SlackertonApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

    # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SlacksWeb.Endpoint.config_change(changed, removed)
    :ok
  end

end
