defmodule Slackerton.News do
  alias Slackerton.News.Api
  alias Slackerton.Cache

  def latest_for(query) do
    latest = Cache.get({__MODULE__, :latest})
    case Api.latest_for(query) do
      {:ok, %{ "articles" => [%{"title" => title } = article] }} 
        when title != latest ->
          Cache.set({__MODULE__, :latest}, title, [ttl: 86400])
          article_markdown(article)

      {:ok, %{ "articles" => articles }} ->
        "Sorry, there's nothing new about \"#{query}\" right now."

      _ ->
        "Sorry, I couldn't get the latest news at this time."
    end
  end

  defp article_markdown(article) do
    source_name = get_in(article, ["source", "name"])
    published_at =  attempt_format(article["publishedAt"])

    """
    *#{article["title"]}*
    _#{source_name} - #{published_at}_

    #{article["description"]}
    #{article["url"]}
    """
  end

  def attempt_format(date) do 
    with {:ok, datetime} <- attempt_parse(date),
         {:ok, formatted_string} <- Timex.format(datetime, "%A, %B %e, %Y", :strftime)
    do
      formatted_string
    else
      _ -> date
    end
  end

  def attempt_parse(date) do
    if String.contains?(date, ".") do
      Timex.parse(date, "%Y-%m-%dT%k:%M:%S.%LZ", :strftime)
    else 
      Timex.parse(date, "%Y-%m-%dT%k:%M:%SZ", :strftime)
    end
  end
end