defmodule Slackerton.Responders.Trivia do
  @moduledoc """
  Listener for trivia game.
  """
  use Hedwig.Responder
  alias Slackerton.{Trivia, Normalize}


  hear ~r/^a$|^b$|^c$|^d$|^e$/i, %{user: user, text: text,} = msg do
    room = Normalize.room(msg.room)
    if Trivia.in_quiz(room) do
      Trivia.answer(room, user, text)
    end
    :ok
  end

end