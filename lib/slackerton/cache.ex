defmodule Slackerton.Cache do

  @moduledoc """
  We don't do a blue green deployment, so instead we use a persisted cache
  """
  use Nebulex.Cache, otp_app: :slackerton
  alias Slackerton.Cache

  def get_or_else(key, fun, options \\ []) do
    Cache.get(key) || Cache.set(key, fun.(), ttl: Keyword.get(options, :ttl, 86400))
  end

end
