defmodule Slackerton.Responders.Rotator do
  
  alias Hedwig.Responder
  alias Slackerton.Normalize
  use Responder

  @usage "
  rotate <message> - Applies rot13 to encode/decode a message.
  "

  hear ~r/^rotate/, msg do
    rotated = 
      msg.text
      |> String.replace("rotate", "")
      |> String.trim()
      |> Normalize.decode_characters()
      |> encode()

    send(msg, rotated)
  end

  def encode(string, shift \\ 13)
  def encode(<<char>> <> tail, shift) do
    <<rotate(char, shift)>> <> encode(tail, shift)
  end

  def encode(_, _), do: ""

  def rotate(char, shift) when ((char >= ?a) and (char <= ?z)) do
    ?a + rem(char - ?a + shift, 26)
  end

  def rotate(char, shift) when ((char >= ?A) and (char <= ?Z)) do
    ?A + rem(char - ?A + shift, 26)
  end

  def rotate(char, _), do: char

end
