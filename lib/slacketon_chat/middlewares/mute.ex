defmodule SlackertonChat.Middleware.Muted do
  alias Slackerton.Accounts.Muted
  alias SlackertonChat.Helpers
  @behaviour SlackertonChat.Middleware

  def call(msg, state) do
    id = Helpers.user_id(msg.user)
    team = Helpers.get_private(msg, "team")

    if Muted.is_muted?(id, team) do
      msg = Helpers.set_private(msg, "muted", true)
      {:halt, msg, state}
    else
      {:next, msg, state}
    end
  end
end