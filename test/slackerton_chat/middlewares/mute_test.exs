defmodule SlackertonChat.Middleware.MutedTest do
  use ExUnit.Case
  alias SlackertonChat.Middleware.Muted

  test "it does not set muted on private if the user is muted" do
    msg = %{user: %{ id: "test", team: "team" }, private: %{} }
    state = %{ opts: [team: "test"]}
    assert Muted.call(msg, state) == { :next, msg, state}
  end

  test "it does not set muted on private if the user is muted" do
    msg = %{user: %{ id: "test", team: "team" }, private: %{} }
    state = %{ opts: [team: "test"]}

    {:halt, msg, state} = Muted.call(msg, state)
    assert %{ private: %{ "muted" => true } } = msg
  end

end