defmodule Slackerton.Cache.Warmer do
  use GenServer
  require Logger
  alias Slackerton.Accounts.User
  alias Slackerton.Settings.Setting
  alias Slackerton.Repo

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
    Logger.debug("Warming the Cache")
    {:ok, _users} = Repo.all(User)
    {:ok, _setting} = Repo.all(Setting)

    Logger.debug("Cache warmed. Shutting down.")
    {:stop, :normal, state}
  end

end