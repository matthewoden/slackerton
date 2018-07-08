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

    Enum.each(users, fn user -> 
      Cache.set({Slackerton.User, user.id}, users) 
      
      if user.is_muted do
        Cache.update({Slackerton.User, :muted}, MapSet.new([user.id], &MapSet.put(&1, user.id)))
      end

    end)
 
    Logger.debug("User Cache warmed. Shutting down.")
    {:stop, :normal, state}
  end

end