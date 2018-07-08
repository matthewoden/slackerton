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
      {:ok, %{ type: "disambiguation"} } ->
        "Could you be a little more specific? \"#{String.capitalize(query)}\" is a little ambiguous."

      {:ok, %{ title: title, extract: extract }} ->
        """

        *#{title}*
        #{extract}
        """

       _ ->
        "Sorry, I don't know about that." 
    end
  end

end

