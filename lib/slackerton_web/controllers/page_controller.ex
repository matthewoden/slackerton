defmodule SlackertonWeb.PageController do
  use SlackertonWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
