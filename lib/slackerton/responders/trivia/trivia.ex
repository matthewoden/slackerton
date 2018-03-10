defmodule Slackerton.Responders.Trivia do
  @moduledoc """
  Ask a trivia question.
  `slap <username> | me
  """
  use Hedwig.Responder
  alias Hedwig.Message
  alias Slackerton.Slack
  alias Slackerton.Responders.Trivia

  @usage """
  pop quiz - Asks a trivia question
  """

  hear ~r/^pop quiz/i, msg do

    if Trivia.Quiz.in_quiz() do
      send msg, "One question at a time, please."
    else
      Trivia.Quiz.new()
      Process.send_after(self(), {:times_up, msg}, 10_000)
      send msg, Trivia.Quiz.prompt()
    end
  end

  @usage """
  a! b! c! d! (during a quiz) - Answer the current trivia question.
  """

  hear ~r/^a!|^b!|^c!|^d!|^e!/i, %{user: user, text: text} = msg do
    if Trivia.Quiz.in_quiz() do
      Trivia.Quiz.answer(user, text)
    end
  end

  
  def handle_info({:times_up, msg}, state) do 
    Trivia.Quiz.finish()
    pid = :global.whereis_name("slackerton")

    Slackerton.Robot.broadcast(%Message{
      robot: pid,
      room: msg.room,
      text: Trivia.Quiz.display_results(),
      type: "message"
    })

    {:noreply, state}
  end
end