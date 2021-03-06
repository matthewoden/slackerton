defmodule Slackerton.DadJokes.Api do
  import HttpBuilder
  alias Slackerton.DadJokes.Api

  @http Application.get_env(:slackerton, :http_adapter, HttpBuilder.Adapters.HTTPoison)
  @json Application.get_env(:slackerton, :json_parser, Jason)

  def get(term) do
    client()
    |> get("/search")
    |> with_query_params(%{ "term" => term })
    |> send()
    |> parse_search_response(term)
  end

  def random() do
    client()
    |> get("")
    |> send()
    |> parse_random_response()
  end
  
  defp client() do
    HttpBuilder.new()
    |> with_adapter(@http)
    |> with_json_parser(Jason)
    |> with_host("https://icanhazdadjoke.com/")
    |> with_headers(%{"accept" => "application/json"})
    |> with_receive_timeout(30_000)
  end

  # TODO: break text out into a seperate module
  defp parse_search_response({:ok, %{status_code: 200, body: body}}, phrase) do
    case @json.decode(body) do
      {:ok, %{ "results" => [] }} ->
        if String.ends_with?(phrase, "s") do
          maybe_singular = String.replace_suffix(phrase, "s", "")
          Api.get(maybe_singular)
        else
          "I don't know any jokes about '#{phrase}'. What about this? \n #{random()}"
        end

      {:ok, %{ "results" => results }} ->
        results
        |> Enum.map(fn %{ "joke" => joke } -> joke end)
        |> Enum.random()

      _ ->
        "Oh no, something went horribly wrong."
    end
  end

  defp parse_search_response(_,_), do: "Oh no, something went horribly wrong"

  defp parse_random_response({:ok, %{status_code: 200, body: body}}) do
    case @json.decode(body) do
      {:ok, %{ "joke" => joke }} -> 
        joke

      _ ->
        "Uh.. Oh no. something went horribly wrong"
    end
  end

  defp parse_random_response(_), do: "Oh no, something went horribly wrong"

end