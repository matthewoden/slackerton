defmodule SlackertonChat do
  alias Hedwig.{Robot, Message}


  def broadcast(team, room, text) do
    case :global.whereis_name(team) do
      :undefined -> 
        :ok
  
      pid ->
        Robot.send(pid, %Message{
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
  
    Robot.send(msg.robot, msg)
  end
  
  def thread(%{private:  %{"ts" => thread_ts }} = msg, response, options) do
    msg =
      Map.merge(msg, %{ 
        text: response,
        thread_ts: thread_ts,
        reply_broadcast: Keyword.get(options, :reply_broadcast, false)
      })
    
    Robot.send(msg.robot, msg)
  end
  
  def thread(msg, response, _options) do   
    Robot.send(msg.robot, %{ msg | text: response })
  end
  
  def reply(msg, text), do: Robot.reply(msg.robot, %{ msg | text: text})
  
  def send(msg, text), do: Robot.send(msg.robot, %{ msg | text: text })
  

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(_) do
    quote do
      import SlackertonChat
    end
  end
end


