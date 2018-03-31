defmodule Lex.Runtime.Request do

  @moduledoc """
  Methods for defining a runtime request.

  You can chain methods together, or cast a single request object. 

    def bot_client() do
      Request.new()
      |> Request.set_bot_name("slackbot")
      |> Request.set_bot_alias("prod")
    end

    def send_input(message) do
      bot_client()
      |> Request.set_user_id(message.user.id)
      |> Request.set_text_input(message.text)
      |> Request.send()
      |> handle_response(message)
    end

  """

  @type t :: %__MODULE__{
    bot_name: String.t,
    bot_alias: String.t,
    user_id: String.t,
    context: String.t,
    type: :text,
    session_attributes: %{ optional(String.t) => String.t } | nil,
    request_attributes: %{ optional(String.t) => String.t } | nil,
    input: String.t
  }

  defstruct bot_name: "", bot_alias: "", user_id: "", context: "default", session_attributes: nil, 
            request_attributes: nil, type: :text, input: ""

  @doc """
  Creates a new request. You can provide inital struct values here.
  """
  def new(params \\ %{}) do
    Map.merge(%__MODULE__{}, params)
  end

  @doc """
  Sets the bot name
  """
  def set_bot_name(%__MODULE__{} = request, value) do
    Map.put(request, :bot_name, value)
  end

  @doc """
  Sets the bot alias for the request
  """
  def set_bot_alias(%__MODULE__{} = request, value) do
    Map.put(request, :bot_alias, value)
  end

  @doc """
  Sets the user id for the request for conversations. Under the covers, the bot 
  alias and request context are appended to the id.
  """
  def set_user_id(%__MODULE__{} = request, value) do
    Map.put(request, :user_id, value)
  end

  @doc """
  Sets the context for the current interaction. Used to see if a user is in a 
  conversation before submitting text.

  For example, you might keep track of a 'ts' value in slack to have your bot 
  reply as a thread, and only respond to replies in that thread. 
  
  Will be appended to the user id as part of the request.
  """
  def set_context(%__MODULE__{} = request, value) do
    Map.put(request, :context, value)
  end

  @doc """
  Set the response type for the request. At this time, you can set the attribute
  to any of the following message types:

  * "PlainText" - The message contains plain UTF-8 text.
  * SSML — The message contains text formatted for voice output.
  * CustomPayload — The message contains a custom format that you have created for 
    your client. 
  """
  def set_response_type(%__MODULE__{} = request, value) do
    set_request_attributes(request, %{"x-amz-lex:accept-content-types" => value })
  end

  @doc """
   set the time zone for the request.

   You can set the attribute to any of the Internet Assigned Number Authority 
   (IANA) time zone names. For the list of time zone names, see the List of tz 
   database time zones on [Wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).
  """
  def set_time_zone(%__MODULE__{} = request, value) do
    set_request_attributes(request, %{ "x-amz-lex:time-zone" => value })
  end

  @doc """
  set the text input for the request.
  """
  def set_text_input(%__MODULE__{} = request, value) do
    request
    |> Map.put(:input, value)
    |> Map.put(:type, :text)
  end

  @doc """
  set session attributes for the request.
  """
  def set_session_attributes(%__MODULE__{} = request, map) when is_map(map) do
    Map.update(request, :session_attributes, map, &Map.merge(&1, map))
  end

  @doc """
  set custom request attributes for the request.
  """
  def set_request_attributes(%__MODULE__{} = request, map) when is_map(map) do
    Map.update(request, :request_attributes, map, &Map.merge(&1, map))
  end

  @doc """
  send the request.
  """
  def send(%__MODULE__{type: :text, input: _input} = request) do
    Lex.Http.post_text(request)
  end

end
