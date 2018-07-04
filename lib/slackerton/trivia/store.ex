defmodule Slackerton.Trivia.Store do
  use GenServer
  require Logger

  defstruct [ active: MapSet.new(), recently_asked: MapSet.new(), quiz: Map.new(), winners: Map.new() ]

  def start_link(_) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state }
  end

  def start_quiz(room) do
    update(fn state ->
      state
      |> Map.update!(:active, fn active -> MapSet.put(active, room) end)
      |> Map.update!(:winners, fn winners -> Map.put(winners, room, MapSet.new()) end)
    end)
  end

  def add_questions_to_quiz(room, quiz) do
    update(fn state ->
      state
      |> Map.update!(:quiz, &Map.put(&1, room, quiz))
      |> Map.update!(:recently_asked, &MapSet.put(&1, quiz.question))
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

  defp update_key(key, callback) do
    GenServer.call(__MODULE__, {:update, key, callback})
  end 

  defp update(callback) do
    GenServer.call(__MODULE__, {:update, callback})
  end

  defp get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def schedule_completion(room, callback, timeout \\ 15_000) do
    Logger.info(fn -> {"Scheduling End of Game", [room: room] } end)
    Process.send_after(__MODULE__, {:times_up, room, callback}, timeout)
  end

  def handle_info({:times_up, room, callback}, state) do
    state = Map.update!(state, :active, &MapSet.delete(&1, room))
    quiz = Map.get(state, :quiz)[room]
    winners = Map.get(state, :winners)[room]
    callback.({quiz, winners})
    {:noreply, state}
  end

  def handle_info(message, state) do
    Logger.warn(fn -> { "unhandled message", [message: message] } end)
    {:noreply, state}
  end

  def handle_call({:update, key, callback}, _, state) do
    state = Map.update!(state, key, callback)
    {:reply, state, state}
  end

  def handle_call({:update, callback}, _, state) do
    state = callback.(state)
    {:reply, state, state}

  end

  def handle_call({:get, key }, _ , state) do
    value = Map.get(state, key)
    {:reply, value, state}
  end
end