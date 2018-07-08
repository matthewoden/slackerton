defmodule Slackerton.Robot do
  require Logger
  use Hedwig.Robot, otp_app: :slackerton

  alias Hedwig.Message
  alias Slackerton.Responders.NaturalLanguage
  alias Slackerton.{Normalize, Dispatcher, Cache}
  alias Lex.Runtime.Conversations

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

  def handle_in(%Hedwig.Message{} = msg, state) do
    NaturalLanguage.handle_conversations(msg)
    {:dispatch, msg, state}
  end

  def handle_in(_, state) do
    {:noreply, state}
  end

  def broadcast(msg) do
    Hedwig.Robot.send(msg.robot, msg)
  end

  def thread(msg, response, options \\ []) 

  def thread(%{private:  %{"ts" => thread_ts }} = msg, response, options) do
    broadcast(Map.merge(msg, %{ 
      text: response,
      thread_ts: thread_ts,
      reply_broadcast: Keyword.get(options, :reply_broadcast, false)
    }))
  end

  def thread(msg, response, _options) do   
    broadcast(%{msg | text: response })
  end

  def send(msg, text) do
    broadcast(Map.merge(msg, %{ text: text }))
  end

end
