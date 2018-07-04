defmodule Slackerton.WordnikTest do
  use ExUnit.Case
  alias Slackerton.Wordnik

  test "define returns numbered definitions" do
    assert Wordnik.define("cat") === """
    Cat
    _noun_
    1 A small carnivorous mammal (Felis catus or F. domesticus) domesticated since early times as a catcher of rats and mice and as a pet and existing in several distinctive breeds and varieties.
    2 Any of various other carnivorous mammals of the family Felidae, which includes the lion, tiger, leopard, and lynx.
    3 The fur of a domestic cat.
    """
  end

  test "define handles unknown words" do
    assert Wordnik.define("asdf") === "Sorry, I don't seem to know that word."
  end

  test "pronounce delivers a sound file with a source" do
    assert Wordnik.pronounce("cat") === """
    Here's the pronounciation for 'cat', from The American Heritage® Dictionary of the English Language, 4th Edition"
    http://api.wordnik.com/v4/audioFile.mp3/c4502f2f96b67dd94bb80ba719831ad8045c8b2d54fa8d410b6178b1e4dac3ed
    """
  end

  test "pronounce handles unknown words" do
    assert Wordnik.pronounce("asdf") === "Sorry, I don't seem to know that word."
  end

  test "example gives a usage example" do
    assert Wordnik.example("cat") === """
    >In a subsequent passage, \"I am as melancholy as a gibb'd cat\" -- we are told that _cat_ is not the domestic animal of that name, but a contraction of _catin_, a woman of the town.
    - _Famous Reviews_, 1899, http://api.wordnik.com/v4/mid/d32e5e6e501b3f60a78301cff9b15d9d5f8dd801afa6bebe188982a42466bb5b
    """

  end

  test "example handles unknown words" do
    assert Wordnik.example("asdf") === "Sorry, I don't seem to know that word."
  end

end