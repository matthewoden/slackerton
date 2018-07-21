defmodule Slackerton.Repo do
  require Logger

  defdelegate scan(mod, params), to: Slackerton.Repo.Dynamo
  defdelegate get(mod, id), to: Slackerton.Repo.Dynamo
  defdelegate all(mod), to: Slackerton.Repo.Dynamo
  defdelegate upsert(mod, id, query), to: Slackerton.Repo.Dynamo
  defdelegate delete(mod, key), to: Slackerton.Repo.Dynamo

end
