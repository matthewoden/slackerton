defmodule Slackerton.Trivia.Store do
  use Agent

  defstruct [ active: MapSet.new(), recently_asked: MapSet.new(), quiz: Map.new(), winners: Map.new() ]

  def start_link(_) do
    Agent.start_link(fn ->  %__MODULE__{} end, name: __MODULE__)
  end

  def start_quiz(room) do
    update(fn state ->
      state
      |> Map.update!(:active, fn active -> MapSet.put(active, room) end)
      |> Map.update!(:winners, fn winners -> Map.put(winners, room, MapSet.new()) end)
      |> IO.inspect()
    end)
  end

  def add_questions_to_quiz(room, quiz) do
    update(fn state ->
      state
      |> Map.update!(:quiz, &Map.put(&1, room, quiz))
      |> Map.update!(:recently_asked, &MapSet.put(&1, quiz.question))
      |> IO.inspect()
    end)
  end

  def answer_quiz(room, user, answer) do
    formatted_answer = String.upcase(answer)

    case get(:quiz)[room] do
      %{correct: ^formatted_answer} ->
        update_key(:winners, &Map.update!(&1, room, fn set -> MapSet.put(set, user) end))

      _ ->
        :ok
    end
  end


  def get_quiz(room), do: Map.get(get(:quiz), room)



  def get_winners(room), do: get(:winners)[room]

  def active?(room), do: get(:active) |> MapSet.member?(room)

  def recently_asked?(question), do: get(:recently_asked) |> MapSet.member?(question)

  def finish_quiz(room), do: update_key(:active, &MapSet.delete(&1, room))

  defp update_key(key, callback) do
    Agent.update(__MODULE__, fn state -> Map.update!(state, key, callback) end)
  end

  defp update(callback) do
    Agent.update(__MODULE__, fn state -> callback.(state) end)
  end

  defp get(key) do
    Agent.get(__MODULE__, fn state -> Map.get(state, key) end)
  end
end