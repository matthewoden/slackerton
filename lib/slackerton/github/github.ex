defmodule Slackerton.Github do
  alias Slackerton.Github.Api

  def feature_request(request, original_message) do
    issue = 
      Api.create_issue(
        "Feature Request: #{request}", 
        """
        Slackerton User request:
        ```
        #{original_message}
        ```
        """
      )
      |>IO.inspect  
      
    case issue do
      {:ok, url} ->
        "Ok, I've created a feature request here: #{url}"

      _ ->
        "Uh, hang on. I can't seem to do that right now."
    end
  end
end