defmodule Slackerton.Responders.Search do
  alias Slackerton.Responders.Search.{Site, Wikipedia}
  alias Slackerton.Slack
  use Hedwig.Responder
  
  @usage """
  search starfinder|pathfinder <query> - searches the SRD, returning the first result for your query.
  """
  
  hear ~r/^search starfinder/i, msg do
    result = search_site("q starfinder", msg.text, "starfindersrd.com")
    reply msg, result
  end

  hear ~r/^search pathfinder/i, msg do
    result = search_site("q pathfinder", msg.text, "d20pfsrd.com")
    reply msg, result
  end

  @usage """
  wiki <query> - Searches wikipedia, returning the first result.
  """

  hear ~r/^wiki/i, msg do
    reply msg, search_wikipedia(msg.text)
  end

  defp search_wikipedia(query) do
    query
    |> String.replace("wiki", "", global: false)
    |> String.trim()
    |> Wikipedia.search()
  end

  defp search_site(handler, message, site) do
    message
    |> String.replace(handler, "", global: false)
    |> String.trim()
    |> Site.search("site:#{site}")
  end

end

