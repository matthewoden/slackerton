defmodule SlackertonChat.Middleware do
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