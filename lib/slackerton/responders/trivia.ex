defmodule Slackerton.Responders.Trivia do
  @moduledoc """
  Ask a trivia question.
  `slap <username> | me
  """
  use Hedwig.Responder
  alias Slackerton.{Trivia, Normalize}

  @usage """
  pop quiz - Asks a trivia question. Answer with the letters provided.
  """

  hear ~r/^pop quiz/i, msg do
    room = Normalize.room(msg.room)
    trivia_loop = Trivia.new(room, fn results -> send(msg, results) end)

    send(msg, trivia_loop)
  end

  hear ~r/^a$|^b$|^c$|^d$|^e$/i, %{user: user, text: text,} = msg do
    room = Normalize.room(msg.room)
    if Trivia.in_quiz(room) do
      Trivia.answer(room, user, text)
    end
    :ok
  end

end