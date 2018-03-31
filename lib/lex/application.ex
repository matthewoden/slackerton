defmodule Lex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Lex.Runtime.Conversations, []},
    ]

    opts = [strategy: :one_for_one, name: Lex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end