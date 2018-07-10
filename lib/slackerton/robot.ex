defmodule Slackerton.Robot do
  require Logger
  use Hedwig.Robot, otp_app: :slackerton

  alias Hedwig.Message
  alias Slackerton.Responders.NaturalLanguage
  alias Slackerton.Cache

  def handle_connect(%{opts: opts} = state) do
    team = Keyword.get(opts, :team)
    if :undefined == :global.whereis_name(team) do
      :yes = :global.register_name(team, self())
    end

    Cache.update(__MODULE__, [team], fn (bots) -> [ team | bots ] end)
    {:ok, state}
  end

  def handle_disconnect(_reason, state) do
    {:reconnect, 5000, state}
  end

  def handle_in(%Message{} = msg, state) do
    NaturalLanguage.handle_conversations(msg)
    {:dispatch, msg, state}
  end

  def handle_in(_, state) do
    {:noreply, state}
  end

  def broadcast(msg) do
    Hedwig.Robot.send(msg.robot, msg)
  end

  def broadcast_all(text, room) do
    robots = Cache.get(__MODULE__)

    Enum.each(robots, fn (robot) -> 
      pid = :global.whereis_name(robot)
      ref = make_ref()

      Hedwig.Robot.send(pid, %Message{
        room: room,
        text: text,
        user: "slackerton",
        type: "message",
      }) 
    end)
  end

  def thread(msg, response, options \\ []) 

  def thread(%{private:  %{"ts" => thread_ts }} = msg, response, options) do
    msg
    |> Map.merge(%{ 
      text: response,
      thread_ts: thread_ts,
      reply_broadcast: Keyword.get(options, :reply_broadcast, false)
    })
    |> broadcast()
  end

  def thread(msg, response, _options) do   
    broadcast(%{ msg | text: response })
  end

  def send(msg, text) do
    broadcast(%{ msg | text: text })
  end

end
