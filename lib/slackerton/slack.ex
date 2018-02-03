defmodule Slackerton.Slack do
  
  def to_user_string(user) when is_binary(user), do: "<@#{user}>"  

  def to_user_string(%{id: id}), do: "<@#{id}>" 

  def escape_characters(msg) do
    msg
    |> String.replace("&", "&amp")
    |> String.replace("<", "&lt")
    |> String.replace(">", "&gt")
  end

  def decode_characters(msg) do
    msg
    |> String.replace("&amp;", "&")
    |> String.replace("&lt;", "<")
    |> String.replace("&gt;", ">")
  end

end