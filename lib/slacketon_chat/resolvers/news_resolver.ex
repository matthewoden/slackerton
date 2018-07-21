defmodule SlackertonChat.NewsResolver do
  alias Hedwig.Responder
  alias Slackerton.News
  alias SlackertonChat.Attachment

  def latest_news(msg, %{ "Topic" => topic }) do

    case News.latest_for(topic) do
      {:ok, article} ->
        msg
        |> attach_article(article)
        |> Responder.send("Here's the latest on '#{topic}':'")

      {:error, :unchanged} ->
        Responder.send(msg, "Sorry, there's nothing new about \"#{topic}\" right now.")

      _ ->
        Responder.send(msg, "Sorry, I couldn't get the latest news about \"#{topic}\" at this time.")
    end
  end

  defp attach_article(msg, article) do
    Attachment.new()
    |> Attachment.fallback(article["url"])
    |> Attachment.title(article["title"], article["url"])
    |> Attachment.text(article["description"])
    |> Attachment.image(article["urlToImage"])
    |> Attachment.author(article["source"]["name"])
    |> Attachment.footer(article["author"])
    |> Attachment.compile()
    |> Attachment.attach(msg)
  end

end