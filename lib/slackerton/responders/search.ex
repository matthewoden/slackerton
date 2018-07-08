defmodule Slackerton.Responders.Search do
  alias Slackerton.{Google, Wikipedia}
  use Hedwig.Responder
  
  @usage """
  wiki <query>*- Searches wikipedia, returning the first result.
  google <query> - gets the first google results for your query.
  search starfinder|pathfinder <query> - searches the SRD, returning the first result for your query.
  """
  
  hear ~r/^search starfinder/i, msg do
    reply msg, search_google("search starfinder", msg.text, "site:starjammersrd.com")
  end

  hear ~r/^search pathfinder/i, msg do
    reply msg, search_google("search pathfinder", msg.text, "site:d20pfsrd.com")
  end 

  hear ~r/^wiki/i, msg do
    reply msg, search_wikipedia(msg.text)
  end

  hear ~r/google/i, msg do
    reply msg, search_google("google", msg.text)
  end


  defp search_wikipedia(query) do
    query
    |> String.replace("wiki", "", global: false)
    |> String.trim()
    |> Wikipedia.search()
  end

  defp search_google(handler, message, prefix \\ "") do
    message
    |> String.replace(handler, "", global: false)
    |> String.trim()
    |> Google.search(prefix)
  end

end

