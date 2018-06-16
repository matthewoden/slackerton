defmodule Slackerton.Responders.Search.Site do
  alias HttpBuilder, as: Http
  require Logger
  
  @google_base_url "https://www.google.com/search"
  @adapter Application.get_env(:slackerton, :http_adapter, Http.Adapters.HTTPoison)

  def search(query, site \\ "") do
    Http.new()
    |> Http.with_adapter(@adapter)
    |> Http.with_json_parser(Jason)
    |> Http.get(@google_base_url)
    |> Http.with_query_params(%{"q" => String.trim("#{site} #{query}")})
    |> Http.send()
    |> handle_response()
    |> get_first_result(query)
  end

  def handle_response(response) do
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> 
        {:ok, body }
      
      otherwise ->
        Logger.error(inspect(otherwise)) 
        {:error, "Could not complete request."}
    end
  end

  defp get_first_result({:ok, html}, query) do

    if String.contains?(html, "did not match any documents.") do
      failed_search(query)
    else
      result = 
        html
        |> Floki.find(".r a")
        |> Enum.at(0, [])
        |> Floki.attribute("href")
        |> IO.inspect()
        |> Enum.at(0, "")
        |> URI.decode_query()
        |> Map.get("/url?q")
    
      result || failed_search(query)
    end

  end

  defp get_first_result({:error, message}, _query), do: message

  defp failed_search(query) do
    "Could not find any results for '#{query}.''"
  end
  
end