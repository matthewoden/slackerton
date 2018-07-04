defmodule Slackerton.News.Api do

  import HttpBuilder
  require Logger

  @config Application.get_env(:slackerton, __MODULE__)
  @http Keyword.get(@config, :http_adapter)
  @json Keyword.get(@config, :json_parser, Jason)
  @api_key Keyword.get(@config, :api_key)

  @base_url "https://newsapi.org/v2"
  @sources ["al-jazeera-english", "associated-press", "politico", "reuters", 
              "the-new-york-times", "the-washington-post"]


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

  defp parse_response({:ok, %{status_code: 200, body: body}}) do    
    @json.decode(body)
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