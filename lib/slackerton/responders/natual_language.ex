defmodule Slackerton.Responders.NaturalLanguage do
  require Logger

  alias Hedwig.{Responder}
  alias Slackerton.{DadJokes,Wordnik,Trivia,News,Normalize}
  alias Lex.Runtime.{Response,Request}
  use Responder

  @usage "hey doc <ask for a joke> - Returns a joke."

  hear ~r/^hey doc/i, msg do
    input = 
      msg.text
      |> String.replace("hey doc", "")
      |> String.trim()
      |> Normalize.decode_characters()
      
    put_text(input, user(msg), context(msg)) |> converse(msg)

    :ok
  end

  def put_text(input, user, context) do
    Request.new()
    |> Request.set_bot_name("Slackerton")
    |> Request.set_bot_alias("dev")
    |> Request.set_context(context)
    |> Request.set_user_id(user)
    |> Request.set_text_input(input)
    |> Request.send()
  end

  def context(%{ private: %{ "thread_ts" => context }}), do: context
  def context(%{ private: %{ "ts" => context }}), do: context
  def context(_), do: "default"

  def user(msg), do: Normalize.user_id(msg.user)

  # loop through the main conversational hooks:
  # - what did you mean?
  # - did you mean x?
  # - can you elaborate further on x?
  # - great, here's x.
  def converse(response, msg) do
    case response do
      %Response.ElicitIntent{ message: message } ->
        Slackerton.Robot.thread(msg, message)

      %Response.ConfirmIntent{ message: message } ->
        Slackerton.Robot.thread(msg, message)

      %Response.ElicitSlot{ message: message } ->
        Slackerton.Robot.thread(msg, message)

      %Response.ReadyForFulfillment{ intent_name: intent, slots: slots } ->
        fulfillment(intent, slots, msg)
    end
  end

  def fulfillment(intent, slots, msg) do
    Logger.debug(intent)
    case intent do
      "DadJokes" ->
        Slackerton.Robot.thread(msg, DadJokes.Api.get(slots["Genre"]), [reply_broadcast: true])

      "DefineWord" ->
        Slackerton.Robot.send(msg, Wordnik.define(slots["Word"]))

      "PronounceWord" ->
        Slackerton.Robot.send(msg, Wordnik.pronounce(slots["Word"]))

      "ExampleWord" ->
        send(msg, Wordnik.example(slots["Word"]))

      "TriviaGame" ->
        room = Normalize.room(msg.room)
        trivia_loop = Trivia.new(room, fn results -> send(msg, results) end)
        send(msg, trivia_loop)

      "GetNews" ->
        send(msg, News.latest_for(slots["Topic"]))
    end
  end

end       