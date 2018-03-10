defmodule Slackerton.Responders.Trivia.Quiz do
  alias Slackerton.Responders.Trivia
  alias Slackerton.Slack
  alias Slackerton.Brain

  use Agent 
  
  defstruct [:question, :correct, :choices, :winners, :in_quiz]


  def new() do
    quiz = %__MODULE__{in_quiz: true, winners: MapSet.new()}

    Brain.add(__MODULE__, quiz)
    
    {question, correct, choices} = Trivia.Api.get()
    IO.inspect correct
    Brain.update(__MODULE__, fn quiz -> 
      Map.merge(quiz, %{
        question: question,
        choices: choices,
        correct: correct,
      }) 
    end)
  end

  def prompt() do
    %{question: question, choices: choices} = get_quiz()

    choice_list = 
      choices
      |> Enum.map(fn {choice, answer} -> "#{choice}) #{answer}" end) 
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

  def answer(%{id: id}, answer), do: record_answer(id, answer)
  def answer(user, answer), do: record_answer(user, answer)

  defp record_answer(id, answer) do
    formatted_answer = String.upcase(answer) |> String.replace("!", "")

    case get_quiz() do
      %{correct: ^formatted_answer} ->
        update_quiz(:winners, fn winners -> MapSet.put(winners, id) end)

      _ ->
        :ok
    end
  end


  def display_results() do
    quiz = get_quiz()
    """
    Times Up!

    The answer was: #{quiz.correct}

    Winners for this round: #{format_winners(MapSet.to_list(quiz.winners))}
    """
  end

  def format_winners([]) do
    "...Nobody!"
  end

  def format_winners(winners) do
    winners
    |> Enum.map(&Slack.to_user_string/1) 
    |> Enum.join(", ")
  end

  def finish() do
    update_quiz(:in_quiz, fn _ -> false end)
  end

  def in_quiz() do
    case get_quiz() do
      nil -> 
        false

      %{ in_quiz: result } ->
        result
    end
  end

  defp get_quiz() do
    Brain.get(__MODULE__)
  end

  defp update_quiz(key, fun) do
    Brain.update(__MODULE__, fn quiz -> Map.update!(quiz, key, fun) end)
  end

end