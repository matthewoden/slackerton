defmodule Slackerton.Wikipedia do
  alias Slackerton.Wikipedia.Api
  require Logger

  def search(query) do
    case Api.summarize(query) do
      {:ok, %{ url: url }} -> url
      {:error, _ } -> "Could not find anything for #{query}"
    end
  end


  def summarize(query) do
    case Api.summarize(query) do
      {:ok, %{ title: title, extract: extract }} ->
        """
        *#{title}*
        #{extract}
        """

       _ ->
        "I have no idea." 
    end
  end

end

