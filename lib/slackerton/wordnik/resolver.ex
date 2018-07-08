defmodule Slackerton.WordnikResolver do
  alias Slackerton.Wordnik
  alias Hedwig.Responder

  def define_word(msg, %{ "Word" => word }) do
    Responder.send(msg, Wordnik.define(word))
  end

  def pronounce_word(msg, %{ "Word" => word}) do
    Responder.send(msg, Wordnik.pronounce(word))
  end  

  def example_word(msg, %{"Word" => word}) do
    Responder.send(msg, Wordnik.example(word))
  end
end