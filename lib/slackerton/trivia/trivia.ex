defmodule Slackerton.Trivia do
  alias Slackerton.Trivia.{Api, Store}
  alias Slackerton.Normalize

  def new(room) do
    Store.start_quiz(room)
    Store.add_questions_to_quiz(room, get_new_quiz())
  end

  def get_new_quiz() do
    %{ question: question } = quiz = Api.get()

    if Store.recently_asked?(question) do
      get_new_quiz()
    else
      quiz
    end

  end

  def prompt(room) do
    %{ question: question, choices: choices } = Store.get_quiz(room)

    choice_list = 
      choices
      |> Enum.map(fn {choice, answer} -> "#{choice} #{answer}" end) 
      |> Enum.join("\n")
    
    answer_list = 
      choices
      |> Enum.map(fn {choice, _} -> "#{choice}" end) 
      |> Enum.join(", ")

    """
    POP QUIZ HOT SHOT:
    #{question}

    Choices: 
    #{choice_list}

    Reply with just: #{answer_list}
    """
  end

  def answer(room, %{id: user}, answer), do: Store.answer_quiz(room, user, answer)
  def answer(room, user, answer), do: Store.answer_quiz(room, user, answer)

  def display_results(room) do
    quiz = Store.get_quiz(room)
    winners = Store.get_winners(room) |> MapSet.to_list() |> format_winners()

    """
    Times Up!

    The answer was: #{quiz.correct}

    Winners for this round: #{winners}
    """
  end

  def format_winners([]), do:  "...Nobody!"
  def format_winners(winners) do
    winners
    |> Enum.map(&Normalize.to_user_string/1) 
    |> Enum.join(", ")
  end

  def finish(room), do: Store.finish_quiz(room)

  def in_quiz(room), do: Store.active?(room)
    
end