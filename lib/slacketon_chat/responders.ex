defmodule SlackertonChat.Responders do
  use Hedwig.Responder
  alias SlackertonChat.TriviaResolver
  alias SlackertonChat.{Lex, Helpers, DadJokesResolver, TriviaResolver}

  @usage """
  Natural Language: Say 'doc' or 'hey doc', then ask for something like the following:
  ... tell me a joke - Returns a joke.
  ... lets play trivia - Asks a trivia question. Answer with the letters provided.
  ... what's the latest on / whats the news about <topic> - Grabs the top trending news from one of 63 sources.
  ... what is / who is / where is <thing> - Provides general knowledge
  ... can you define / how do you pronounce / can you give an example of <thing> - grammar information
  
  Weather Alerts:
  ... put severe weather alerts in here
  ... remove weather alerts from here

  Feature Requests:
  ... feature request: <request> - Files a feature request on the github project.

  Admin Controls:
  ... add @user as an admin - adds a user as an admin
  ... remove @user from admins - removes user from admins
  ... list admins - lists admins for the current slack team

  ... ignore @user - stop responding to a user
  ... unignore @user - stop ignoring a user 
  ... list ignored - lists all ignored users for the current team
  """

  hear ~r/^hey doc|^doc|^dev/i, msg do
    
    input = 
      msg.text
      |> String.replace(~r/hey doc|doc|dev/, "", global: false)
      |> String.trim()
      |> Helpers.decode_characters()
      
    Lex.put_text(input, Lex.user(msg), Lex.context(msg)) |> Lex.converse(msg)

    :ok
  end  

  # other resolvers

  hear ~r/^a$|^b$|^c$|^d$|^e$/i, msg, do: TriviaResolver.answer_question(msg, %{})
  hear ~r/(I'm)|(I’m)/i, msg, do: DadJokesResolver.say_hello(msg, %{})
  
end