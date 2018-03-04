defmodule Slackerton.Responders.NaturalLanguage do
  alias Hedwig.{Responder}
  alias Slackerton.Responders.NaturalLanguage.Wolfram
  alias Slackerton.Slack

  use Responder

  @usage "hey doc <question?> - checks various sources for an answer."

  hear ~r/^hey doc/, msg do
    answer = 
      msg.text
      |> String.replace("hey doc", "")
      |> String.trim()
      |> Slack.decode_characters()
      |> Wolfram.short_answer(%{})

    reply(msg, answer)
  end
end       