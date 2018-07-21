defmodule SlackertonChat.Middleware.Robot do
  alias SlackertonChat.Helpers
  @behaviour SlackertonChat.Middleware

  def call(msg, state) do
    robot = Keyword.get(state.opts, :team)
    msg = Helpers.set_private(msg, "robot", robot)
    {:next, msg, state}
  end
  
end