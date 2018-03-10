defmodule Slackerton.Responders.Trivia do
  @moduledoc """
  Ask a trivia question.
  `slap <username> | me
  """
  use Hedwig.Responder
  alias Hedwig.Message
  alias Slackerton.Responders.Trivia.Quiz

  @usage """
  pop quiz - Asks a trivia question
  """

  hear ~r/^pop quiz/i, msg do

    if Quiz.in_quiz() do
      send msg, "One question at a time, please."
    else
      Quiz.new()
      Process.send_after(self(), {:times_up, msg}, 15_000)
      send msg, Quiz.prompt()
    end
  end

  @usage """
  a! b! c! d! (during a quiz) - Answer the current trivia question.
  """

  hear ~r/^a$|^b$|^c$|^d$|^e$/i, %{user: user, text: text} do
    if Quiz.in_quiz() do
      Quiz.answer(user, text)
    else
      :ok
    end
  end

  
  def handle_info({:times_up, msg}, state) do 
    Quiz.finish()
    pid = :global.whereis_name("slackerton")

    Slackerton.Robot.broadcast(%Message{
      robot: pid,
      room: msg.room,
      text: Quiz.display_results(),
      type: "message"
    })

    {:noreply, state}
  end
end