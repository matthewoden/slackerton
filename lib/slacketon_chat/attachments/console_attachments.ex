defmodule SlacketonChat.Attachments.Console do
  @behaviour SlackertonChat.Attachments.Adapter

  #TODO: pretty print
  def attach(attach, msg) do
    %{ msg | text: msg.text <> "\n #{inspect(attach)}" }
  end

end