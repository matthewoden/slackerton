defmodule SlackertonTest do
  use ExUnit.Case
  doctest Slackerton

  test "greets the world" do
    assert Slackerton.hello() == :world
  end
end
