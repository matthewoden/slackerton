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
        Map.put(query, "location", options.location)
      else
        query
      end

    HttpBuilder.new()
    |> with_adapter(@http)
    |> with_host("https://api.wolframalpha.com/v1")
    |> with_query_params(query)
    |> with_receive_timeout(30_000)
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
    @json.decode(body)
  end

  @misunderstood [
    "Sorry, I don't understand what you want. Maybe be a little more specific?",
    "Not quite sure what you mean - could you rephrase the question?",
    "I don't know what you're looking for. Could you try asking a different way?"
  ]
  def parse_response({:ok, %{ body: "Wolfram|Alpha did not understand your input"}}, _) do
    Enum.random(@misunderstood)
  end

  @unknown [
    "Hmm. I'm not sure.",
    "Good question. I have no idea.",
    "Google it yourself."
  ]

  def parse_response(error, _) do
    Logger.error(inspect(error)) 
    Enum.random(@unknown)
  end
  
end