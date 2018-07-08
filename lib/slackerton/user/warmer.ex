defmodule Slackerton.User.CacheWarmer do
  use GenServer
  require Logger
  alias Slackerton.User.Repo
  alias Slackerton.Cache

  @moduledoc """
  Fetches user data, warms the cache, then dies.
  """

  def start_link() do
    GenServer.start_link(__MODULE__, [:ok], name: __MODULE__)
  end

  def init(state) do
    send(self(), :work)
    {:ok, state}
  end

  def handle_info(:work, state) do
    Logger.debug("Warming the User Cache")
    {:ok, users} = Repo.all()

    Logger.debug("User Cache warmed. Shutting down.")
    {:stop, :normal, state}
  end

end