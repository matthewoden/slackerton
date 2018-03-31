defmodule Slackerton.Responders.NaturalLanguage do

  alias Hedwig.{Responder}
  alias Slackerton.Responders.NaturalLanguage.{DadJokes}
  alias Slackerton.Normalize
  alias Lex.Runtime.Response

  use Responder

  @usage "hey doc <ask for a joke> - Returns a joke."


  hear ~r/(I'm)|(I’m)/i, msg do
    IO.inspect("testing")
    subject =
      msg.text
      |> Normalize.decode_characters()
      |> String.split(~r/I'm/i, [parts: 2])
      |> IO.inspect()
      |> Enum.at(1)
      |> String.trim()

    reply msg, "Hi #{subject}, I'm dad!"
  end

  hear ~r/^hey doc/i, msg do
    input = 
      msg.text
      |> String.replace("hey doc", "")
      |> String.trim()
      |> Normalize.decode_characters()
      
    Lex.put_text(input, user(msg), context(msg)) |> converse(msg)
    :ok
  end

  def context(%{ private: %{ "thread_ts" => context }}), do: context
  def context(%{ private: %{ "ts" => context }}), do: context
  def context(_), do: "default"

  def user(msg), do: Normalize.user_id(msg.user)

  def converse(response, msg) do
    case response do
      %Response.ElicitIntent{ message: message, } ->
        Slackerton.Robot.thread(msg, message)

      %Response.ConfirmIntent{ message: message } ->
        Slackerton.Robot.thread(msg, message)

      %Response.ElicitSlot{ message: message } ->
        Slackerton.Robot.thread(msg, message)

      %Response.ReadyForFulfillment{ intent_name: _intent, slots: slots } ->
        Slackerton.Robot.thread(msg, DadJokes.get(slots["Genre"]), [reply_broadcast: true])

      %Response.Failed{  } ->
        Slackerton.Robot.thread(msg, "Sorry, something went wrong." )

      %Response.Error{ } ->
        Slackerton.Robot.thread(msg, "Sorry, something went wrong." )
    end
  end

end       