defmodule SlackertonChat.Middleware do

  @moduledoc """
  Middlewares are essentially hooks into the message flow before dispatching, and 
  can short-circuit other responders.

  Here's an example of a mute middleware, which fetches the user, potentially 
  halting any response from the slackbot:

    def call(msg, state) do
      id = Helpers.user_id(msg.user)
      team = Helpers.get_private(msg, "team")

      if Muted.is_muted?(id, team) do
        msg = Helpers.set_private(msg, "muted", true)
        {:halt, msg, state}
      else
        {:next, msg, state}
      end
    end
  
  TODO: This could probably be a struct, like Conn. Then it'd be decoupled from 
  hedwig
  """

  @type state :: map
  @type msg :: map
  @type action :: :next | :halt | :mute

  @callback call(msg, state) ::  {action, msg, state}

  def dispatch(middlewares, msg, state) do
    Enum.reduce_while(middlewares,  [msg, state], fn (mod, args) -> 
      case apply(mod, :call, args)  do
        {:next, msg, state} -> { :cont, [msg, state] }
        {:halt, msg, state} -> { :halt, [msg, state] }
      end
    end)
  end
end