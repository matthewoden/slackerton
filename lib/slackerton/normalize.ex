defmodule Slackerton.Normalize do
  
  def to_user_string(user) when is_binary(user), do: "<@#{user}>"  

  def to_user_string(%{id: id}), do: "<@#{id}>" 

  def room(nil), do: "default"
  def room(room), do: room

  def user_id(user) when is_binary(user), do: user
  def user_id(%{id: id}), do: id

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
    |> String.replace("’", "'")
  end

end