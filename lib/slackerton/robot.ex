defmodule Slackerton.Robot do
  use Hedwig.Robot, otp_app: :slackerton

  def handle_connect(%{name: name} = state) do
    if :undefined == :global.whereis_name(name) do
      :yes = :global.register_name(name, self())
    end

    {:ok, state}
  end

  def handle_disconnect(_reason, state) do
    {:reconnect, 5000, state}
  end

  def handle_in(%Hedwig.Message{} = msg, state) do
    {:dispatch, msg, state}
  end

  def handle_in(_msg, state) do
    {:noreply, state}
  end

  def broadcast(msg) do
    pid = :global.whereis_name("slackerton")
    Hedwig.Robot.send(pid, msg)
  end

end
