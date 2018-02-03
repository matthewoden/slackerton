defmodule Slackerton.Responders.Search.Wikipedia do
  alias HttpBuilder, as: Http
  require Logger

  @base_url "https://en.wikipedia.org/w/api.php"

  def search(query) do
    Http.new()
    |> Http.with_adapter(Http.Adapters.HTTPoison)
    |> Http.get(@base_url)
    |> Http.with_query_params(%{
        "action" => "opensearch",
        "search"=> query,
        "limit"=> 1,
        "namespace"=> 0,
        "format"=>"json",
        })
    |> Http.send()
    |> handle_response(query)
  end

  def handle_response(response, query) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response,
         {:ok, [ _, _, _, [ url | _ ] ] } <- Jason.decode(body)
    do 
      url
    else
      otherwise ->
        Logger.error(inspect(otherwise)) 
        "Could not complete request for '#{query}'."
    end
  end

end

