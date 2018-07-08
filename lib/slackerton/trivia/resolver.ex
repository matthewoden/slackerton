defmodule Slackerton.TriviaResolver do
  alias Slackerton.{Normalize, Trivia}
  alias Hedwig.Responder

  def start_game(msg, _slots) do
    room = Normalize.room(msg.room)
    trivia_loop = Trivia.new(room, fn results -> Responder.send(msg, results) end)
    Responder.send(msg, trivia_loop)
  end

end