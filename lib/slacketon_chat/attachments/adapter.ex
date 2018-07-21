defmodule SlackertonChat.Attachments.Adapter do
  @type msg :: Hedwig.Message
  @type attachment :: SlackertonChat.Attachment

  @callback attach(attachment, msg) :: msg

end