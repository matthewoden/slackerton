defmodule SlackertonChat.TriviaResolver do
  alias SlackertonChat.{Robot, Helpers}
  alias Slackerton.Trivia

  def start_game(msg, _slots) do
    room = Helpers.room(msg.room)
    trivia_loop = Trivia.new(room, fn results -> Robot.send(msg, results) end)
    Robot.send(msg, trivia_loop)
  end

  def answer_question(%{user: user, text: text, room: room}, _) do
    room = Helpers.room(room)
    user = Helpers.to_user_string(user)
    if Trivia.in_quiz(room) do
      Trivia.answer(room, user, text)
    end

    :ok
  end

end