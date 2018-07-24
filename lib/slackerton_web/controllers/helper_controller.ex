defmodule SlackertonWeb.HelperController do
  use SlackertonWeb, :controller

  def index(conn, _params) do
    render conn, "ping.json", ping: true
  end
end
