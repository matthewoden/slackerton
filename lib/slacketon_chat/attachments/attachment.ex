defmodule SlackertonChat.Attachment.Field do
  defstruct [title: nil, value: nil, short: true ]
    
  def new(params) do
    %__MODULE__{}
    |> Map.merge(params)
  end

  def title(field, title) when is_binary(title) do
    %{ field | title: title }
  end

  def title(field, value) when is_binary(value) do
    %{ field | value: value }
  end

  def small(field) do
    %{ field | short: true }
  end

  def large(field) do
    %{ field | short: true }
  end

end

defmodule SlackertonChat.Attachment do
  alias SlackertonChat.Attachments.{Slack, Console}

  @config Application.get_env(:slackerton, SlackertonChat.Robot)
  @adapter Keyword.get(@config, :adapter)
  @attacher if @adapter == Hedwig.Adapters.Slack, do: Slack, else: Console

  defstruct [
    fallback: nil,
    color: "#000",
    pretext: nil,
    author_name: nil,
    author_link: nil,
    author_icon: nil,
    title: nil,
    title_link: nil,
    text: nil,
    fields: [],
    image_url: nil,
    thumb_url: nil,
    footer: nil,
    footer_icon: nil,
    ts: nil
  ]

  def new(params \\ %{}) do
    struct(__MODULE__, Enum.to_list(params))
  end

  def fallback(attach, text) when is_binary(text) do
    %{ attach | fallback: text }
  end

  def color(attach, hex) when is_binary(hex) do
    %{ attach | color: hex }
  end

  def pretext(attach, text) when is_binary(text) do
    %{ attach | pretext: text }
  end

  def author(attach, name, link \\ nil, icon \\ nil) when is_binary(name) do
    %{ attach | author_name: name, author_link: link, author_icon: icon }
  end

  def field(attach, field) do
    %{ attach | fields: Enum.reverse([ field | attach.fields ]) }
  end 

  def fields(attach, fields) do
    %{ attach | fields: fields}
  end

  def title(attach, text, link \\ nil) when is_binary(text) do
    %{ attach | title: text, title_link: link}
  end

  def text(attach, text) when is_binary(text) do
    %{ attach | text: text}
  end

  def image(attach, url) when is_binary(url) do
    %{ attach | image_url: url }
  end
  def thumbnail(attach, url) when is_binary(url) do
    %{ attach | thumbnail_url: url }
  end

  def footer(attach, text, icon \\ nil) when is_binary(text) do
    %{ attach | footer: text, footer_icon: icon }
  end

  def timestamp(attach, timestamp) do
    %{ attach | ts: timestamp }
  end

  def compile(attach) do
    attach
    |> Map.from_struct()
    |> Enum.filter(fn {_key, value} -> value != nil end)
    |> Map.new()
  end

  defdelegate attach(attachment, msg), to: @attacher

end



