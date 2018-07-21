defmodule Slackerton.News do
  alias Slackerton.News.Api
  alias Slackerton.Cache
  require Logger

  def latest_for(query) do

    latest = Cache.get({__MODULE__, :latest})
    case Api.latest_for(query) do

      {:ok, [ %{"title" => title } = article | _rest ] }
        when title != latest ->
          Cache.set({__MODULE__, :latest}, title, [ttl: 86400])
          {:ok, article}

      {:ok, [] } ->
          {:error, :no_news} 

      {:ok, [ %{"title" => title } | _rest ] }
        when title == latest ->
          {:error, :no_news} 

      otherwise ->
        Logger.debug("#{__MODULE__}: #{inspect(otherwise)}")
        {:error, :api_failure}
    end
  end

end