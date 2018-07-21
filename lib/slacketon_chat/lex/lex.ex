defmodule SlackertonChat.Lex do
  require Logger
  alias Lex.Runtime.{Response,Request,Conversations}
  alias SlackertonChat.{Router, Robot, Helpers}
  alias Slackerton.Accounts.Admin

  def converse(response, msg) do
    userId = Helpers.user_id(msg.user)
    teamId = Helpers.team_id(msg)

    case response do
      %Response.ElicitIntent{ message: message } ->
        Robot.thread(msg, message)

      %Response.ConfirmIntent{ message: message } ->
        # TODO: Create middleware for callbacks?
        if Admin.is_admin?(userId, teamId) do
          Robot.thread(msg, message)
        else 
          Robot.thread(msg, Admin.reject())
          put_text("stop", user(msg), context(msg))
        end

      %Response.ElicitSlot{ message: message } ->
        Robot.thread(msg, message)

      %Response.Failed{ message: message } ->
        Robot.thread(msg, message)

      %Response.Error{ data: data } ->
        Logger.error(inspect(data))
        Robot.thread(msg, "Oh no, something terrible happened. Maybe try that again in a bit.")

      %Response.ReadyForFulfillment{ intent_name: intent, slots: slots } ->
        Router.dispatch(intent, msg, slots)
    end
  end

  def handle_conversations(msg) do
    userId = user(msg)
    contextId = context(msg)
    
    if Conversations.in_conversation?(userId, contextId) do
      Logger.debug("IN CONVERSATION > #{userId} #{contextId}")

      input = 
        msg.text
        |> String.trim()
        |> Helpers.decode_characters()

      put_text(input, userId, contextId) 
      |> converse(msg)
    end
  end

  def put_text(input, user, context) do
    Request.new()
    |> Request.set_bot_name("Slackerton")
    |> Request.set_bot_alias("dev")
    |> Request.set_context(context)
    |> Request.set_user_id(user)
    |> Request.set_text_input(input)
    |> Request.send()
  end

  def context(%{ private: %{ "thread_ts" => context }}), do: context
  def context(%{ private: %{ "ts" => context }}), do: context
  def context(_), do: "default"

  def user(msg), do: Helpers.user_id(msg.user)

end