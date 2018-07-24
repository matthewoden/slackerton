defmodule SlackertonWeb.HelperView do
  use SlackertonWeb, :view

  def render("ping.json", %{ping: ping}) do
    %{
      ping: true
    }
  end
end