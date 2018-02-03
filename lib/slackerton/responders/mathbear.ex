defmodule Slackerton.Responders.Mathbear do
  @moduledoc """
  Makes a decision based on input
  """
  alias Hedwig.{Message, Responder}
  use Responder

  @usage "mathbear <options> - Makes a decision based on input. Format: mathbear pick 1 is left. 2 is right."

  @initial_state %{ 
    current_option: "", 
    current_number: nil, 
    previous: nil, 
    options: %{} 
  }

  hear ~r/^mathbear/i, msg, do: mathbear_message(msg)

  defp mathbear_message(msg) do
    msg
    |> parse_message()
    |> parse_options(@initial_state)
    |> choose_option()
    |> format_option()
    |> flip_send(msg)
  end

  defp flip_send(response, msg), do: send(msg, response)

  def parse_message(%Message{matches: matches, text: text}) do
    matches
    |> Map.values()
    |> Enum.reduce(text, fn match, text -> String.trim(text, match) end)
    |> String.split(" ", trim: true)
  end

  defp parse_options([], state) do
      state = update_options(state)
      state.options
  end
  
  defp parse_options([ "is" | tail ], %{ previous: { :number, number } } = state) do
    state = 
      state
      |> update_options()
      |> Map.merge(%{ 
          previous: { :word, "is" },
          current_option: "",
          current_number: number 
        })

    parse_options(tail, state)
  end

  defp parse_options([ word | tail ], state) do
    previous = 
      case Integer.parse(word) do
        {integer, ""} ->
          {:number, integer}

        _ -> 
          {:word, word }
      end

    state = update_current_and_previous(state, word, previous)

    parse_options(tail, state)
  end

  
  defp update_options(%{current_number: nil} = state), do: state

  defp update_options(%{current_number: key, current_option: value} = state) do
    %{ state | options: Map.put(state.options, key, value) }
  end

  defp update_current_and_previous(state, _word, {:number, _integer} = previous) do
    %{state | previous: previous}
  end

  defp update_current_and_previous(%{current_option: ""} = state, word, previous) do
    %{state | current_option: word, previous: previous}
  end

  defp update_current_and_previous(%{current_option: current} = state, word, previous) do
    %{state | current_option: "#{current} #{word}", previous: previous}
  end

  defp choose_option(options) do
    case Map.to_list(options) do
      [_head | _] = options ->
        Enum.random(options)
      [] ->
        option_error()
    end    
  end 

  defp option_error do
    {"Error", "I'm a Math Bear, not a mind reader. Try again with something like, \"mathbear decide 1 is left 2 is right.\""}
  end

  defp format_option({key, value}), do: "#{key}: #{value}"
  

end
