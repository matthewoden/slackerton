defmodule Lex do
  @moduledoc false

  alias Lex.Runtime.{Request}

  @config Application.get_env(:slackerton, Lex, [])
  @bot_alias Keyword.get(@config, :bot_alias, "dev")
  @bot_name Keyword.get(@config, :bot_name, "Slackerton")

  
  def put_text(input, user, context) do
    Request.new()
    |> Request.set_bot_name(@bot_name)
    |> Request.set_bot_alias(@bot_alias)
    |> Request.set_context(context)
    |> Request.set_user_id(user)
    |> Request.set_text_input(input)
    |> Request.send()
  end

  def demo() do
    put_text("tell me a joke", "test", "thread")
  end

end
