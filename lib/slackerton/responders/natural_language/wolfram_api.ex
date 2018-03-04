defmodule Slackerton.Responders.NaturalLanguage.Wolfram do
  require Logger
  import HttpBuilder

  @http Application.get_env(:slackerton, :http_adapter, HttpBuilder.Adapters.HTTPoison)
  @json Application.get_env(:slackerton, :json_decoder, Jason)
  @app_id Application.get_env(:slackerton, :wolfram_key)

  defp client(options \\ %{}) do
    query = %{
      "appid" => @app_id,
      "output" => "json",
      "location" => "St. Louis, MO"
    }

    query = 
      if Map.get(options, :location) do
        Map.update(query, "location", options.location)
      else
        query
      end

    HttpBuilder.new()
    |> with_adapter(@http)
    |> with_host("https://api.wolframalpha.com/v1")
    |> with_query_params(query)
  end
  
  def simple(question, options) do
    client(options)
    |> get("/simple")
    |> with_query_params(%{ "i" => question })
    |> send()
    |> parse_response(:text)
  end

  def short_answer(question, options) do
    client(options)
    |> get("/result")
    |> with_query_params(%{ "i" => question })
    |> send()
    |> parse_response(:text)
  end

  def parse_response({:ok, %{status_code: 200, body: body}}, :text) do
    body
  end

  def parse_response({:ok, %{status_code: 200, body: body}}, :json) do
    Json.decode(body)
  end

  def parse_response(error, _) do
    Logger.error(inspect(error)) 
    Enum.random([
      "Hmm. I'm not sure.",
      "Good question. I have no idea.",
      "Google it yourself."
    ])
  end
  
end