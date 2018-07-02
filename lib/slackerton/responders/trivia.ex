defmodule Slackerton.Responders.Trivia do
  @moduledoc """
  Ask a trivia question.
  `slap <username> | me
  """
  use Hedwig.Responder
  alias Hedwig.Message
  alias Slackerton.Trivia

  @usage """
  pop quiz - Asks a trivia question
  """

  hear ~r/^pop quiz/i, %{room: room} = msg do
    if Trivia.in_quiz(room) do
      send msg, "One question at a time, please."
    else
      Trivia.new(room)
      Process.send_after(self(), {:times_up, msg}, 15_000)
      send msg, Trivia.prompt(room)
    end
  end

  @usage """
  a b c d e (during a quiz) - Answer the current trivia question.
  """

  hear ~r/^a$|^b$|^c$|^d$|^e$/i, %{user: user, text: text, room: room} do
    if Trivia.in_quiz(room) do
      Trivia.answer(room, user, text)
    else
      :ok
    end
  end

  
  def handle_info({:times_up, msg}, state) do 
    Trivia.finish(msg.room)

    Slackerton.Robot.broadcast(%Message{
      robot: msg.robot,
      room: msg.room,
      text: Trivia.display_results(msg.room),
      type: "message"
    })

    {:noreply, state}
  end
end