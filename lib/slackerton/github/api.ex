defmodule Slackerton.Github.Api do
  import HttpBuilder
  require Logger

  @config Application.get_env(:slackerton, __MODULE__)
  @http Keyword.get(@config, :http_adapter)
  @json Keyword.get(@config, :json_parser, Jason)
  @repo Keyword.get(@config, :repo)

  @base_url "https://api.github.com"

  def client() do
    HttpBuilder.new()
    |> with_adapter(@http)
    |> with_json_parser(Jason)
    |> with_host(@base_url)
    |> with_headers(%{ "authorization" => "token #{System.get_env("SLACKERTON_GITHUB_TOKEN")}"})
    |> with_receive_timeout(30_000)
  end

  def create_issue(title, body) do
    Logger.debug("Creating issue title='#{title}' body='#{inspect(body)}''")
    request = 
      client()
      |> post("/repos/#{@repo}/issues")
      |> with_json_body(%{ 
          "title" => title, 
          "body" => body, 
          "labels" => ["Enhancement"],
        })
      |> send()

    case request do
      {:ok, %{status_code: 201, body: body}} ->
        url = @json.decode!(body)["html_url"]
        {:ok, url}

      otherwise ->
        Logger.debug(inspect(otherwise))
        {:error, :failed}
    end
  end
end