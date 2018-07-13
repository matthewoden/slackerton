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
          article_markdown(article)

      {:ok, %{ "articles" => _ }} ->
        "Sorry, there's nothing new about \"#{query}\" right now."

      otherwise ->
        Logger.debug(inspect(otherwise))
        "Sorry, I couldn't get the latest news at this time."
    end
  end

  # article should auto expand. Markdown not needed
  defp article_markdown(article) do
    article["url"]
  end

end