defmodule Slackerton.NewsResolver do
  alias Hedwig.Responder
  alias Slackerton.News

  def get_latest(msg, %{ "Topic" => topic }) do
    Responder.send(msg, News.latest_for(topic))
  end

end