defmodule Slackerton.Responders.DadJokes do
  @moduledoc """
  The laziest dad joke. Fires only 1 in 10 times.

  "I'm so tired today."

  "Hi 'so tired today', I'm dad!"
  """
  
  alias Hedwig.{Responder}
  alias Slackerton.Normalize
 
  use Responder



  hear ~r/(I'm)|(I’m)/i, msg do
    case Enum.random(1..10) do
      1 ->
        subject =
          msg.text
          |> Normalize.decode_characters()
          |> String.split(~r/(I'm)|(I’m)/i, [parts: 2])
          |> Enum.at(1)
          |> String.split(~r/\.|\?|,|!/)
          |> Enum.at(0)
          |> String.trim()

        reply msg, "Hi \"#{subject}\", I'm dad!"
        
      _ ->
        :ok
    end
  end

end