defmodule Lex.Runtime.Response.Card do

  @type button :: %{ 
    text: String.t,
    value: String.t
  }
  
  @type generic_attachment :: %{
    attachment_link_url: String.t,
    buttons: [ button ],
    image_url: String.t,
    sub_title: String.t,
    title: String.t
  }

  @type t :: %__MODULE__{
    content_type: String.t,
    generic_attachments: [generic_attachment], 
    version: String.t
  }

  defstruct [ :content_type, :generic_attachments, :version ]

  def cast(json) when is_map(json) do
    %__MODULE__{
      content_type: json["contentType"],
      generic_attachments: cast_attachments(json["genericAttachments"]),
      version: json["version"]
    }
  end

  def cast(_), do: nil

  defp cast_attachments(attachments) when is_list(attachments) do
    Enum.map(attachments, fn (attach) -> 
      %{  
        attachment_link_url: attach["attachmentLinkUrl"],
        buttons: cast_buttons(attach["buttons"]),
        image_url: attach["imageUrl"],
        sub_title: attach["subTitle"],
        title: attach["title"]
      }
    end)
  end

  defp cast_attachments(_), do: []

  defp cast_buttons(buttons) when is_list(buttons) do
    Enum.map(buttons, fn (button) ->  
       %{ text: button["text"],  value: button["value"] }
    end)
  end

  defp cast_buttons(_), do: []

end

defmodule Lex.Runtime.Response.ElicitIntent  do

  @type t :: %__MODULE__{
    user_id: String.t,
    message: String.t,
    message_format: String.t,
    response_card: Lex.Runtime.Response.Card.t,
    session_attributes: map,
  }

  defstruct [ :user_id, :message, :message_format, :response_card, :session_attributes]

  def cast(user_id, json) do
    %__MODULE__{
      user_id: user_id,
      message: json["message"],
      message_format: json["messageFormat"],
      response_card: Lex.Runtime.Response.Card.cast(json["responseCard"]),
      session_attributes: json["sessionAttributes"]
    }
  end
end

defmodule Lex.Runtime.Response.ConfirmIntent  do

  @type t :: %__MODULE__{
    user_id: String.t,
    intent_name: String.t, 
    message: String.t,
    message_format: String.t,
    response_card: Lex.Runtime.Response.Card.t,
    session_attributes: map,
  }

  defstruct [ :user_id, :intent_name, :message, :message_format, :response_card,
              :session_attributes]

  def cast(user_id, json) do
    %__MODULE__{
      user_id: user_id,
      intent_name: json["intentName"], 
      message: json["message"],
      message_format: json["messageFormat"],
      response_card: Lex.Runtime.Response.Card.cast(json["responseCard"]),
      session_attributes: json["sessionAttributes"]
    }
  end
end

defmodule Lex.Runtime.Response.ElicitSlot  do

  @type t :: %__MODULE__{
    user_id: String.t,
    intent_name: String.t, 
    message: String.t,
    message_format: String.t,
    response_card: Lex.Runtime.Response.Card.t,
    session_attributes: map,
    slots: map, 
    slot_to_elicit: String.t,
  }

  defstruct [ :user_id, :intent_name, :message, :message_format, :response_card,
              :session_attributes, :slots, :slot_to_elicit ]

  def cast(user_id, json) do
    %__MODULE__{
      user_id: user_id,
      intent_name: json["intentName"], 
      message: json["message"],
      message_format: json["messageFormat"],
      response_card: Lex.Runtime.Response.Card.cast(json["responseCard"]),
      session_attributes: json["sessionAttributes"],
      slots: json["slots"], 
      slot_to_elicit: json["slotToElicit"]
    }
  end
end

defmodule Lex.Runtime.Response.Fulfilled  do
  @type t :: %__MODULE__{
    user_id: String.t,
    intent_name: String.t, 
    session_attributes: map,
    slots: map, 
  }

  defstruct [ :user_id, :intent_name, :session_attributes, :slots ]

  def cast(user_id, json) do
    %__MODULE__{
      user_id: user_id,
      intent_name: json["intentName"], 
      session_attributes: json["sessionAttributes"],
      slots: json["slots"]
    }
  end

end

defmodule Lex.Runtime.Response.ReadyForFulfillment  do
  @type t :: %__MODULE__{
    user_id: String.t,
    intent_name: String.t, 
    session_attributes: map,
    slots: map, 
  }

  defstruct [ :user_id, :intent_name, :session_attributes, :slots ]

  def cast(user_id, json) do
    %__MODULE__{
      user_id: user_id,
      intent_name: json["intentName"], 
      session_attributes: json["sessionAttributes"],
      slots: json["slots"]
    }
  end

end

defmodule Lex.Runtime.Response.Failed do
  @type t :: %__MODULE__{
    user_id: String.t,
    intent_name: String.t, 
    session_attributes: map,
    slots: map, 
  }

  defstruct [ :user_id, :intent_name, :session_attributes, :slots ]

  def cast(user_id, json) do
    %__MODULE__{
      user_id: user_id,
      intent_name: json["intentName"], 
      session_attributes: json["sessionAttributes"],
      slots: json["slots"]
    }
  end

end

defmodule Lex.Runtime.Response.Error do
  @type t :: %__MODULE__{
    user_id: String.t,
    data: term
  }
  defstruct [ :user_id, :data]

  def cast(user_id, data) do
    %__MODULE__{
      user_id: user_id,
      data: data
    }
  end
end


defmodule Lex.Runtime.Response do
  alias Lex.Runtime.{Response, Conversations}

  @moduledoc """
  Casts the json reply into a struct for more idiomatic handling in elixir.

  Allows iteration over all possible conversation states in a single function.
  
    alias Lex.Runtime.Response

    def handle_response(lex, message) do
      case response do
        %Response.ElicitIntent{ user_id: user_id, message: message, slots: slots } ->
          #...

        %Response.ConfirmIntent{ user_id: user_id, message: message } ->
          #...

        %Response.ElicitSlot{ user_id: user_id, intent_name: intent, message: message } ->
          #...

        %Response.Fulfilled{ user_id: user_id, intent_name: intent, slots: slots } ->
          #...

        %Response.ReadyForFulfillment{ user_id: user_id, intent_name: intent, slots: slots } ->
          #...

        %Response.Failed{ user_id: user_id, intent_name: intent } ->
          #...

        %Response.Error{ } ->
          #...

      end
    end
  """

  def cast(user_id, context, json) do
    case json["dialogState"] do 
      "ElicitIntent" ->
        Conversations.converse(user_id, context)
        Response.ElicitIntent.cast(user_id, json)

      "ConfirmIntent" ->
        Conversations.converse(user_id, context)
        Response.ConfirmIntent.cast(user_id, json)

      "ElicitSlot" ->
        Conversations.converse(user_id, context)
        Response.ElicitSlot.cast(user_id, json)

      "Fulfilled" ->
        Conversations.converse(user_id, context)
        Response.Fulfilled.cast(user_id, json)

      "ReadyForFulfillment" ->
        Conversations.complete(user_id, context)
        Response.ReadyForFulfillment.cast(user_id, json)

      "Failed" ->
        Conversations.complete(user_id, context)
        Response.Failed.cast(user_id, json)

      _ ->
        Conversations.complete(user_id, context)
        Response.Error.cast(user_id, "Unknown Dialog State: #{json["dialogState"]}")
    end
  end

end