defmodule SlackertonChat.WikipediaResolver do
  alias Slackerton.Wikipedia
  alias Hedwig.Responder

  def summarize(msg, %{"Topic" => topic}) do
    Responder.reply(msg, Wikipedia.summarize(topic))
  end

end