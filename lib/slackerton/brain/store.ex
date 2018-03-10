defmodule Slackerton.Brain.Store do
  
  @type store :: map
  @type key :: atom
  @type value :: term

  @callback start_link(term) :: {:ok, true} | {:error, term}

  @callback get(key) :: value
    
  @callback add(key, value) :: :ok
    
  @callback update(key, fun) :: :ok
  
  @callback remove(key) :: :ok

end