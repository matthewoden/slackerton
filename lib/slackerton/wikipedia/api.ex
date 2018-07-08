defmodule Slackerton.Wikipedia.Api do
  @moduledoc """
  REST API for Wikipedia

  They weird redirects (or HTTPoison doesn't handle it correctly, either way),
  so we have to redirects and formatting manually.
  """

  require Logger
  alias HttpBuilder, as: Http

  @base_url "https://en.wikipedia.org/api/rest_v1"
  @user_agent Application.get_env(:slackerton, :user_agent)

  def summarize(query, redirect \\ true, reformat \\ true, count \\ 0)

  def summarize(_, _, _, 5), do: {:error, :too_many_redirects}

  def summarize(query, redirect, reformat, count) do
    Http.new()
    |> Http.with_adapter(Http.Adapters.HTTPoison)
    |> Http.with_host(@base_url)
    |> Http.get("/page/summary/#{prepare_query(query, reformat)}")
    |> Http.with_json_parser(Jason)
    |> Http.with_headers(%{ "User-Agent" => @user_agent })
    |> Http.with_query_params(%{ "redirect" => redirect })
    |> Http.send()
    |> handle_response(count)
  end

  def prepare_query(query, false), do: query
  def prepare_query(query, true) do 
    query
    |> String.split(" ")
    |> Enum.map(fn word ->String.capitalize(word) end)
    |> Enum.join("_")
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}, _count) do
    with {:ok, %{"title" => title, "extract" => extract, "content_urls" => urls }} <- Jason.decode(body) do 
      url = get_in(urls, ["desktop", "page"])
      {:ok, %{title: title, extract: extract, url: url } }
    else
      otherwise ->
        Logger.error(inspect(otherwise)) 
       {:error, :not_enough_info}
    end
  end

  # manual redirect, because they handle the location header strangely.
  defp handle_response({:ok, %HTTPoison.Response{status_code: code, headers: headers}}, count) 
    when code > 300 and code < 400 do 
    {_, value} = Enum.find(headers, fn 
      {"location", _value} -> true 
      {"Location", _value} -> true 
      _ -> false
    end)

    # Custom redirect:
    # - replace any requests for %2B (plus) with an underscore.
    # - continue to allow redirects
    # - do not reformat the query
    # - increase the count
    summarize(String.replace(value, "%2B","_"), true, false, count + 1)
  end
  
  defp handle_response(response) do
    Logger.error(IO.inspect(response))
    {:error, :not_enough_info}
  end
end
