defmodule Slackerton.NewsResolver do
  alias Hedwig.Responder
  alias Slackerton.News

  def latest_news(msg, %{ "Topic" => topic }) do
    Responder.send(msg, News.latest_for(topic))
  end

end