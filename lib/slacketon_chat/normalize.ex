defmodule SlackertonChat.Normalize do
  @moduledoc """
  Normalizes differences between Hedwig Adapters
  """
  def to_user_string(user) when is_binary(user), do: "<@#{user}>"  
  def to_user_string(%{id: id}), do: "<@#{id}>" 

  def user_id(user) when is_binary(user), do: user
  def user_id(%{id: id}), do: id

  def team_id(%{private: %{ "team" => team }}), do: team
  def team_id(_), do: "default"

  def room(nil), do: "default"
  def room(room), do: room

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