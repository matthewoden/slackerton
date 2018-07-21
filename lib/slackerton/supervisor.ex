defmodule Slackerton.Supervisor do
  use Supervisor
  alias Slackerton.{Cache, Trivia}


  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    children = [
      supervisor(Cache, []),
      worker(Cache.Warmer, [], [restart: :temporary]),
      {Trivia.Store, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end