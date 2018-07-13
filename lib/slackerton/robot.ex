defmodule Slackerton.Robot do
  use Hedwig.Robot, otp_app: :slackerton

  require Logger
  alias Hedwig.Message
  alias Slackerton.Responders.NaturalLanguage

  def handle_connect(%{opts: opts} = state) do
    team = Keyword.get(opts, :team)
    if :undefined == :global.whereis_name(team) do
      :yes = :global.register_name(team, self())
    end
    {:ok, state}
  end

  def handle_disconnect(_reason, state) do
    {:reconnect, 5000, state}
  end

  def handle_in(%Message{} = msg, state) do
    # TODO: add middleware concept
    robot = Keyword.get(state.opts, :team)
    private = Map.put(msg.private, "robot", robot)
    msg = Map.put(msg, :private, private)

    NaturalLanguage.handle_conversations(msg)

    {:dispatch, msg, state}
  end

  def handle_in(_, state) do
    {:noreply, state}
  end

  def broadcast(team, room, text) do
    case :global.whereis_name(team) do
      :undefined -> 
        :ok

      pid ->
        Hedwig.Robot.send(pid, %Message{
          text: text,
          room: room,
          type: "message"
        })
    end
  end

  def thread(msg, response, options \\ []) 

  def thread(%{private:  %{"ts" => thread_ts }} = msg, response, options) do
    msg
    |> Map.merge(%{ 
      text: response,
      thread_ts: thread_ts,
      reply_broadcast: Keyword.get(options, :reply_broadcast, false)
    })
    |> send()
  end

  def thread(msg, response, _options) do   
    send(%{ msg | text: response })
  end

  def send(msg) do
    Hedwig.Robot.send(msg.robot, msg)
  end

end
