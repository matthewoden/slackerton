defmodule SlackertonChat.TriviaResolver do
  alias SlackertonChat.{Robot, Normalize}
  alias Slackerton.Trivia

  def start_game(msg, _slots) do
    room = Normalize.room(msg.room)
    trivia_loop = Trivia.new(room, fn results -> Robot.send(msg, results) end)
    Robot.send(msg, trivia_loop)
  end

  def answer_question(%{user: user, text: text, room: room}, _) do
    room = Normalize.room(room)
    user = Normalize.to_user_string(user)
    if Trivia.in_quiz(room) do
      Trivia.answer(room, user, text)
    end

    :ok
  end

end