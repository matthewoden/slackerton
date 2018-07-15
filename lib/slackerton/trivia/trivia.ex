defmodule Slackerton.Trivia do
  alias Slackerton.Trivia.{Api, Store}

  def new(room, on_complete) do
    if in_quiz(room) do
      "One question at a time, please."
    else
      Store.start_quiz(room)
      Store.add_questions_to_quiz(room, get_new_quiz())
      Store.schedule_completion(
        room, 
        fn results -> 
          on_complete.(display_results(results)) 
        end, 
        15_000
      )

      display_prompt(room)
    end
  end

  def get_new_quiz() do
    %{ question: question } = quiz = Api.get()

    if Store.recently_asked?(question) do
      get_new_quiz()
    else
      quiz
    end

  end

  def display_prompt(room) do
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

  def display_results({quiz, winners}) do
    winners =  MapSet.to_list(winners) |> format_winners()

    """
    Times Up!

    The answer was: #{quiz.correct}

    Winners for this round: #{winners}
    """
  end

  def format_winners([]), do:  "...Nobody!"
  def format_winners(winners), do: Enum.join(winners,", ")
    
  def in_quiz(room), do: Store.active?(room)

end