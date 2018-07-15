defmodule SlackertonChat.GithubResolver do
  alias SlackertonChat.Robot
  alias Slackerton.Github

  def feature_request(msg, %{ "FeatureRequest" => feature}) do
    Robot.thread(msg, Github.feature_request(feature, msg.text))
  end
end