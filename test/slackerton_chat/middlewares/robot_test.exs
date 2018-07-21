defmodule SlackertonChat.Middleware.RobotTest do
  use ExUnit.Case
  alias SlackertonChat.Middleware.Robot

  test "robot middlware puts the robot team on the message" do
    msg = %{private: %{} }
    state = %{ opts: [team: "test"]}
    assert Robot.call(msg, state) == { :next, %{ private: %{ "robot" => "test"}} , state}
  end
  
end