defmodule Slackerton do
  @moduledoc false

  use Application
  import Supervisor.Spec, warn: false


  def start(_type, _args) do

    children = [
      {Slackerton.Supervisor, []},
      {SlackertonChat.Supervisor, []}
    ]

    opts = [strategy: :one_for_one, name: SlackertonApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
