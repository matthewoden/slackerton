defmodule SlackertonChat.DadJokesResolver do
  alias SlackertonChat.{Robot, Normalize}
  alias Slackerton.DadJokes

  def tell_joke(msg, %{ "Genre" => genre }) do
    Robot.thread(msg, DadJokes.Api.get(genre), [reply_broadcast: true])
  end

  def say_hello(msg, _) do
    case Enum.random(1..10) do
      10 ->
        subject =
          msg.text
          |> Normalize.decode_characters()
          |> String.split(~r/(I'm)|(I’m)/i, [parts: 2])
          |> Enum.at(1)
          |> String.split(~r/\.|\?|,|!/)
          |> Enum.at(0)
          |> String.trim()

        Robot.reply(msg, "Hi \"#{subject}\", I'm dad!")
        
      _ ->
        :ok
    end
    
  end

end