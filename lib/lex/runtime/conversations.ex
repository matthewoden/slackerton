defmodule Lex.Runtime.Conversations do
  use GenServer

  def start_link(_) do
    state = %{ conversations: %{}, session_timeout: 5 * 60 }
    GenServer.start_link(__MODULE__, state, [name: __MODULE__])
  end

  def init(state) do
    schedule_cleanup()
    {:ok, state }
  end

  def converse(user, context \\ "default") do
    GenServer.cast(__MODULE__, {:converse, user, context})
  end

  def complete(user, context \\ "default") do
    GenServer.cast(__MODULE__, {:complete, user, context})
  end

  def conversations() do
    GenServer.call(__MODULE__, :conversations)
  end

  def in_conversation?(user, context \\ "default") do
    GenServer.call(__MODULE__, {:is_conversing, {user, context}})
  end

  defp schedule_cleanup() do
    Process.send_after(self(), :cleanup, 60 * 1000)
  end

  # Genserver 
  ################

  def handle_info(:cleanup, state) do
    conversations =
      state.conversations
      |> Enum.filter(fn {_, expires} -> 
          now = NaiveDateTime.utc_now()
          expires < now
        end)
      |> Map.new()
      
    state = Map.put(state, :conversations, conversations)

    {:noreply, state}
  end

  def handle_info(_, state), do: {:noreply, state}

  def handle_call({:is_conversing, key}, _from, state) do
    response = 
      case Map.get(state.conversations, key) do
        nil ->
          false

        expires ->
          case NaiveDateTime.compare(expires, NaiveDateTime.utc_now()) do
            :gt -> 
              true
            _ ->
              false
          end
      end

    {:reply, response, state}
  end

  def handle_call(:conversations, _from, state) do
    {:reply, Map.get(state, :conversations), state}
  end

  def handle_cast({:converse, user, context}, state) do
    expires_at = NaiveDateTime.utc_now() |> NaiveDateTime.add(state.session_timeout, :seconds)
    conversations = Map.put(state.conversations, {user, context}, expires_at)
    state = Map.put(state, :conversations, conversations)

    {:noreply, state}
  end

  def handle_cast({:complete, user, context}, state) do
    conversations = Map.delete(state.conversations, {user, context})
    {:noreply, Map.put(state, :conversations, conversations)}
  end

end