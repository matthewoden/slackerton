defmodule Slackerton.DadJokesResolver do
  alias Slackerton.{DadJokes, Robot}

  def tell_joke(msg, %{ "Genre" => genre }) do
    Robot.thread(msg, DadJokes.Api.get(genre), [reply_broadcast: true])
  end

end