defmodule Slackerton.WikipediaResolver do
  alias Hedwig.Responder
  alias Slackerton.Wikipedia

  def summarize(msg, %{"Topic" => topic}) do
    Responder.reply(msg, Wikipedia.summarize(topic))
  end

end