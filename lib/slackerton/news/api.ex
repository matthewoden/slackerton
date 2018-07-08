defmodule Slackerton.News.Api do

  import HttpBuilder
  require Logger

  @config Application.get_env(:slackerton, __MODULE__)
  @http Keyword.get(@config, :http_adapter)
  @json Keyword.get(@config, :json_parser, Jason)
  @api_key Keyword.get(@config, :api_key)

  @base_url "https://newsapi.org/v2"
  @sources ["abc-news", "abc-news-au", "al-jazeera-english", "ars-technica", 
            "associated-press", "axios", "bbc-news", "business-insider",
            "business-insider-uk", "buzzfeed", "cbc-news", "cbs-news", "cnbc",
            "cnn", "engadget", "financial-times", "google-news", "google-news-au", 
            "google-news-ca", "google-news-in", "google-news-uk", "hacker-news",
            "ign", "mashable", "medical-news-today", "metro", "mirror", "msnbc", 
            "mtv-news", "mtv-news-uk", "national-geographic", "nbc-news", 
            "news24", "new-scientist", "news-com-au", "newsweek",
            "new-york-magazine", "next-big-future", "politico", "polygon", 
            "recode", "reddit-r-all", "reuters", "rte", "techcrunch", "techradar",
            "the-economist", "the-globe-and-mail", "the-guardian-au", "the-guardian-uk", 
            "the-hill", "the-hindu", "the-huffington-post", "the-irish-times", 
            "the-jerusalem-post", "the-new-york-times", "the-next-web", 
            "the-telegraph", "the-times-of-india", "the-verge", "the-wall-street-journal", 
            "the-washington-post", "the-washington-times", "time", "usa-today", 
            "vice-news", "wired"
          ]


  def latest_for(query) do
    client()
    |> get("/top-headlines")
    |> with_query_params(%{
      "q" => query,
      "pageSize" => 1,
      "apiKey" => @api_key,
      "sources" => Enum.join(@sources,",")
    })
    |> send()
    |> parse_response()
  end

  @keys ["source", "publishedAt", "title", "description", "url"]

  defp parse_response({:ok, %{status_code: 200, body: body}}) do  
    with {:ok, %{ "articles" => articles }} <- @json.decode(body) do
      Enum.map(articles, &Map.take(&1, @keys))
    end  
  end

  defp parse_response(result) do
    Logger.error(inspect(result))
    :error
  end

  defp client() do
    HttpBuilder.new()
    |> with_adapter(@http)
    |> with_json_parser(Jason)
    |> with_host(@base_url)
    |> with_receive_timeout(30_000)
    end

end