defmodule Slackerton.Responders.Trivia.Api do
  import HttpBuilder
  require Logger
  @http Application.get_env(:slackerton, :http_adapter, HttpBuilder.Adapters.HTTPoison)
  @json Application.get_env(:slackerton, :json_parser, Jason)

  def get() do
    client() |> HttpBuilder.send() |> parse_response()
  end

  defp client() do
    HttpBuilder.new()
    |> with_adapter(@http)
    |> with_json_parser(Jason)
    |> with_host("https://opentdb.com/api.php")
    |> with_query_params(%{
        "amount" => 1,
        "category" => 9,
        "difficulty" => "medium",
        "type" => "multiple",
        "encode" => "url3986"
      })
    |> with_receive_timeout(30_000)
  end

  defp parse_response({:ok, %{status_code: 200, body: body}}) do    
      %{
        "question" => question, 
        "correct_answer" => correct, 
        "incorrect_answers" => incorrect
      } = @json.decode!(body) |> Map.get("results") |> hd
        
      choices = [ URI.decode(correct) | incorrect ]

      lettered_choices = 
        Enum.zip(?A..?Z, Enum.shuffle(choices))
        |> Enum.map(fn ({code, choice}) -> {<<code>>, URI.decode(choice)} end)

      correct = 
        lettered_choices
        |> Enum.find(lettered_choices, fn ({_ , choice }) -> URI.decode(correct) == choice end)
        |> elem(0)

      { URI.decode(question), correct, lettered_choices }
  end

  defp parse_response(result) do
    Logger.error(inspect(result))
    :error
  end
end

