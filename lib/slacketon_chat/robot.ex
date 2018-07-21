defmodule SlackertonChat.Robot do
  use Hedwig.Robot, otp_app: :slackerton
  require Logger
  alias Hedwig.Message
  alias SlackertonChat.{Helpers, Middleware}

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

  def thread(%{private:  %{"thread_ts" => thread_ts }} = msg, response, options) do
    msg = 
      Map.merge(msg, %{ 
        text: response,
        thread_ts: thread_ts,
        reply_broadcast: Keyword.get(options, :reply_broadcast, false)
      })

    Hedwig.Robot.send(msg.robot, msg)
  end

  def thread(%{private:  %{"ts" => thread_ts }} = msg, response, options) do
    msg =
      Map.merge(msg, %{ 
        text: response,
        thread_ts: thread_ts,
        reply_broadcast: Keyword.get(options, :reply_broadcast, false)
      })
    
    Hedwig.Robot.send(msg.robot, msg)
  end

  def thread(msg, response, _options) do   
    Hedwig.Robot.send(msg.robot, %{ msg | text: response })
  end

  def reply(msg, text), do: Hedwig.Robot.reply(msg.robot, %{ msg | text: text})

  def send(msg, text), do: Hedwig.Robot.send(msg.robot, %{ msg | text: text })


  # callbacks

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
    # robot = Keyword.get(state.opts, :team)
    # private = Map.put(msg.private, "robot", robot)
    # msg = Map.put(msg, :private, private)

    # Lex.handle_conversations(msg)
    middlewares = Keyword.get(state.opts, :middlewares, [])
    [msg, state] = Middleware.dispatch(middlewares, msg, state)

    if Helpers.get_private(msg, "muted") do
      {:noreply, state}
    else
      {:dispatch, msg, state}
    end
  end

  def handle_in(_, state) do
    {:noreply, state}
  end

end
