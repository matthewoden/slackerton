defmodule SlackertonChat.Attachments.Slack do
  @behaviour SlackertonChat.Attachments.Adapter

  def attach(attachment, msg) do
    attachments = SlackertonChat.Helpers.get_private(msg, "attatchments", [])
    SlackertonChat.Helpers.set_private(msg, "attachments", [ attachment | attachments ])
  end
  

end