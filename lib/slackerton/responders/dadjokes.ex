defmodule Slackerton.Responders.DadJokes do

  alias Hedwig.{Responder}
  alias Slackerton.Responders.DadJokes
  alias Slackerton.Normalize
 
  use Responder

  @usage "hey doc <ask for a joke> - Returns a joke."


  hear ~r/(I'm)|(I’m)/i, msg do
    case Enum.random(1..10) do
      1 ->
        subject =
          msg.text
          |> Normalize.decode_characters()
          |> String.split(~r/I'm/i, [parts: 2])
          |> Enum.at(1)
          |> String.split(~r/\.|\?|,|!/)
          |> Enum.at(1)
          |> String.trim()

        reply msg, "Hi #{subject}, I'm dad!"
        
      _ ->
        :ok
    end
  end

end