defmodule Slackerton.Responders.Calculate do
  @moduledoc """
  Solves math problems.
  """
  alias Slackerton.Calculate
  alias Hedwig.{Responder} 
  use Responder

  @usage """
  solve <expression> - solves a math problem.
  """

  hear ~r/solve/i, msg do 
    expression = String.replace(msg.text, "solve", "", global: false) |> String.trim()
    reply msg, Calculate.solve(expression)
  end
  
end