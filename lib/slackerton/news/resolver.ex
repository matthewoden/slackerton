defmodule Slackerton.NewsResolver do
  alias Hedwig.Responder

  def get_latest(msg, %{ "Topic" => topic }) do
    Responder.send(msg, News.latest_for(topic))
  end

end