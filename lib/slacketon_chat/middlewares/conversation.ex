defmodule SlackertonChat.Middleware.Conversation do
  alias SlackertonChat.Lex
  @behaviour SlackertonChat.Middleware

  def call(msg, state) do
    Lex.handle_conversations(msg)
    {:next, msg, state}
  end

end