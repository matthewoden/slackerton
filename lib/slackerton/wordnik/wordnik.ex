defmodule Slackerton.Wordnik do
  alias Slackerton.Wordnik.Api
  alias Slackerton.Cache

  def define(word) do
    define_result = Cache.get_or_else({__MODULE__, :define, word}, fn -> Api.define(word) end)

    case define_result do
      {:ok, results} ->
        output = 
          results
          |> Enum.group_by(&Map.get(&1, "partOfSpeech"))
          |> Enum.map(fn ({part, defined}) -> format_definitions(part, defined) end)
          |> Enum.join("\n")
          |> String.trim()
        
        """
        #{String.capitalize(word)}
        #{output}
        """  

      {:error, _} ->
        "Sorry, I don't seem to know that word."
    end
  end

  defp format_definitions(part, items) do
    numbered_definitons = 
      items
      |> Enum.filter(fn x -> Map.has_key?(x, "text") end)
      |> Enum.with_index()
      |> Enum.map(fn {defined, number} -> "#{ number + 1 } #{defined["text"]}"end)
      |> Enum.join("\n")

    """
    _#{part}_
    #{numbered_definitons}

    """
  end

  def pronounce(word) do
    pronounced_result = Cache.get_or_else({__MODULE__, :pronounce, word}, fn -> Api.pronounce(word) end)

    case pronounced_result do
      {:ok, %{"word" => word, "attributionText" => attribution, "fileUrl" => file}} ->
        """
        Here's the pronounciation for '#{word}', #{attribution}"
        #{file}
        """

      _ ->
        "Sorry, I don't seem to know that word."
    end
  end


  def example(word) do
    example_result = Cache.get_or_else({__MODULE__, :example, word}, fn -> Api.example(word) end)

    case example_result do
      {:ok, %{"text" => text, "title" => title, "year" => year, "url" => url }} ->
        """
        >#{text}
        - _#{title || "Unknown Source"}_, #{year || "Unknown Year"}, #{url}
        """

      _ ->
        "Sorry, I don't seem to know that word."    
    end
  end

end