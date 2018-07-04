defmodule Slackerton.Calculate do
  alias Slackerton.Cache
  require Logger

  def solve(expression) do
    trimmed = String.trim(expression)
    memo = Cache.get_or_else({__MODULE__, :eval, trimmed }, 
      fn ->  
        try do
          Abacus.eval(expression) 
        rescue
          e in ArithmeticError -> e
        end
      end)

    case memo do
      {:ok, value} -> 
        value

      %ArithmeticError{message: message } ->
        Logger.error(fn -> "ArithmeticError - #{message}" end)
        "Whoa there cowboy, that's some wild math. I'm not sure I can handle that."
      result ->
        Logger.error(IO.inspect(result))
        "Sorry, I couldn't figure that out."
    end
  end
end