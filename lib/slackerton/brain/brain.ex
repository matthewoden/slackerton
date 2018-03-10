defmodule Slackerton.Brain do
  
  @brain Application.get_env(:slackerton, Slackerton.Brain, [])
  @adapter Keyword.get(@brain, :adapter, Slackerton.Brain.ProcessStore)

  defdelegate start_link(args), to: @adapter
    
  defdelegate get(key), to: @adapter
    
  defdelegate add(key, value), to: @adapter
    
  defdelegate update(key, fun), to: @adapter
  
  defdelegate remove(key), to: @adapter
  
  defdelegate child_spec(opts), to: @adapter
    
end