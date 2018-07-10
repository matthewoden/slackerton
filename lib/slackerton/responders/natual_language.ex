defmodule Slackerton.Responders.NaturalLanguage do
  require Logger
  alias Hedwig.Responder
  alias Lex.Runtime.{Response,Request,Conversations}
  alias Slackerton.Accounts.UserResolver
  alias Slackerton.{Normalize, DadJokesResolver, WordnikResolver, TriviaResolver, 
    NewsResolver, WikipediaResolver}

  use Responder

  @usage """
  Natural Language: Say 'hey doc', then ask for something like the following:
  ... tell me a joke - Returns a joke.
  ... lets play trivia - Asks a trivia question. Answer with the letters provided.
  ... what's the latest on / whats the news about <topic> - Grabs the top trending news from one of 63 sources.
  ... what is / who is / where is <thing> - Provides general knowledge
  ... can you define / how do you pronounce / can you give an example of <thing> - grammar information
  
  Admin Controls:
  ... add @user as an admin - adds a user as an admin
  ... remove @user from admins - removes user from admins
  ... list admins - lists admins for the current slack team
  """

  hear ~r/^hey doc|doc/i, msg do
    input = 
      msg.text
      |> String.replace(~r/hey doc|doc/, "")
      |> String.trim()
      |> Normalize.decode_characters()
      
    put_text(input, user(msg), context(msg)) |> converse(msg)

    :ok
  end  

  #todo - turn into some kind of router.
  def fulfillment(intent, slots, msg) do
    Logger.debug(inspect({intent, slots}))
    case intent do
      "DadJokes" -> DadJokesResolver.tell_joke(msg, slots)

      "DefineWord" -> WordnikResolver.define_word(msg, slots)

      "PronounceWord" -> WordnikResolver.pronounce_word(msg, slots)

      "ExampleWord" -> WordnikResolver.example_word(msg, slots)
      
      "TriviaGame" -> TriviaResolver.start_game(msg, slots)

      "GetNews" -> NewsResolver.latest_news(msg, slots)

      "AddAdmin" -> UserResolver.create_admin(msg, slots)

      "RemoveAdmin" -> UserResolver.delete_admin(msg, slots)
      
      "ListAdmin" -> UserResolver.list_admins(msg, slots)

      "SummarizeTopic" -> WikipediaResolver.summarize(msg, slots)

      _ ->
        :ok
    end
  end

  def handle_conversations(msg) do
    userId = user(msg)
    contextId = context(msg)
    
    if Conversations.in_conversation?(userId, contextId) do
      Logger.debug("IN CONVERSATION > #{userId} #{contextId}")

      input = 
        msg.text
        |> String.trim()
        |> Normalize.decode_characters()

      put_text(input, userId, contextId) 
      |> converse(msg)
    end
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

  defp context(%{ private: %{ "thread_ts" => context }}), do: context
  defp context(%{ private: %{ "ts" => context }}), do: context
  defp context(_), do: "default"

  defp user(msg), do: Normalize.user_id(msg.user)

  defp converse(response, msg) do
    case response do
      %Response.ElicitIntent{ message: message } ->
        Slackerton.Robot.thread(msg, message)

      %Response.ConfirmIntent{ message: message } ->
        Slackerton.Robot.thread(msg, message)

      %Response.ElicitSlot{ message: message } ->
        Slackerton.Robot.thread(msg, message)

      %Response.ReadyForFulfillment{ intent_name: intent, slots: slots } ->
        fulfillment(intent, slots, msg)

      %Response.Failed{ message: message } ->
        Slackerton.Robot.thread(msg, message)
    end
  end

end       