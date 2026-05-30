import gleam/dynamic/decode.{type Decoder}
import gleam/option.{type Option, None}
import max_bot/types/callback.{type Callback}
import max_bot/types/chat.{type Chat}
import max_bot/types/message.{type Message}
import max_bot/types/user.{type User}

pub type Update {
  MessageCreated(
    timestamp: Int,
    message: Message,
    user_locale: Option(String),
  )
  MessageCallback(
    timestamp: Int,
    callback: Callback,
    message: Option(Message),
    user_locale: Option(String),
  )
  MessageEdited(timestamp: Int, message: Message)
  MessageRemoved(
    timestamp: Int,
    message_id: String,
    chat_id: Int,
    user_id: Int,
  )
  BotAdded(
    timestamp: Int,
    chat_id: Int,
    user: User,
    is_channel: Bool,
  )
  BotRemoved(
    timestamp: Int,
    chat_id: Int,
    user: User,
    is_channel: Bool,
  )
  UserAdded(
    timestamp: Int,
    chat_id: Int,
    user: User,
    inviter_id: Option(Int),
    is_channel: Bool,
  )
  UserRemoved(
    timestamp: Int,
    chat_id: Int,
    user: User,
    admin_id: Option(Int),
    is_channel: Bool,
  )
  BotStarted(
    timestamp: Int,
    chat_id: Int,
    user: User,
    payload: Option(String),
    user_locale: Option(String),
  )
  ChatTitleChanged(
    timestamp: Int,
    chat_id: Int,
    user: User,
    title: String,
  )
  MessageChatCreated(
    timestamp: Int,
    chat: Chat,
    message_id: String,
    start_payload: Option(String),
  )
}

pub fn decoder() -> Decoder(Update) {
  use update_type <- decode.field("update_type", decode.string)
  use timestamp <- decode.field("timestamp", decode.int)
  case update_type {
    "message_created" -> {
      use message <- decode.field("message", message.message_decoder())
      use user_locale <- decode.optional_field(
        "user_locale",
        None,
        decode.optional(decode.string),
      )
      decode.success(MessageCreated(timestamp:, message:, user_locale:))
    }
    "message_callback" -> {
      use callback <- decode.field("callback", callback.callback_decoder())
      use message <- decode.optional_field(
        "message",
        None,
        decode.optional(message.message_decoder()),
      )
      use user_locale <- decode.optional_field(
        "user_locale",
        None,
        decode.optional(decode.string),
      )
      decode.success(MessageCallback(
        timestamp:,
        callback:,
        message:,
        user_locale:,
      ))
    }
    "message_edited" -> {
      use message <- decode.field("message", message.message_decoder())
      decode.success(MessageEdited(timestamp:, message:))
    }
    "message_removed" -> {
      use message_id <- decode.field("message_id", decode.string)
      use chat_id <- decode.field("chat_id", decode.int)
      use user_id <- decode.field("user_id", decode.int)
      decode.success(MessageRemoved(
        timestamp:,
        message_id:,
        chat_id:,
        user_id:,
      ))
    }
    "bot_added" -> {
      use chat_id <- decode.field("chat_id", decode.int)
      use user <- decode.field("user", user.user_decoder())
      use is_channel <- decode.field("is_channel", decode.bool)
      decode.success(BotAdded(timestamp:, chat_id:, user:, is_channel:))
    }
    "bot_removed" -> {
      use chat_id <- decode.field("chat_id", decode.int)
      use user <- decode.field("user", user.user_decoder())
      use is_channel <- decode.field("is_channel", decode.bool)
      decode.success(BotRemoved(timestamp:, chat_id:, user:, is_channel:))
    }
    "user_added" -> {
      use chat_id <- decode.field("chat_id", decode.int)
      use user <- decode.field("user", user.user_decoder())
      use inviter_id <- decode.optional_field(
        "inviter_id",
        None,
        decode.optional(decode.int),
      )
      use is_channel <- decode.field("is_channel", decode.bool)
      decode.success(UserAdded(
        timestamp:,
        chat_id:,
        user:,
        inviter_id:,
        is_channel:,
      ))
    }
    "user_removed" -> {
      use chat_id <- decode.field("chat_id", decode.int)
      use user <- decode.field("user", user.user_decoder())
      use admin_id <- decode.optional_field(
        "admin_id",
        None,
        decode.optional(decode.int),
      )
      use is_channel <- decode.field("is_channel", decode.bool)
      decode.success(UserRemoved(
        timestamp:,
        chat_id:,
        user:,
        admin_id:,
        is_channel:,
      ))
    }
    "bot_started" -> {
      use chat_id <- decode.field("chat_id", decode.int)
      use user <- decode.field("user", user.user_decoder())
      use payload <- decode.optional_field(
        "payload",
        None,
        decode.optional(decode.string),
      )
      use user_locale <- decode.optional_field(
        "user_locale",
        None,
        decode.optional(decode.string),
      )
      decode.success(BotStarted(
        timestamp:,
        chat_id:,
        user:,
        payload:,
        user_locale:,
      ))
    }
    "chat_title_changed" -> {
      use chat_id <- decode.field("chat_id", decode.int)
      use user <- decode.field("user", user.user_decoder())
      use title <- decode.field("title", decode.string)
      decode.success(ChatTitleChanged(timestamp:, chat_id:, user:, title:))
    }
    "message_chat_created" -> {
      use chat <- decode.field("chat", chat.chat_decoder())
      use message_id <- decode.field("message_id", decode.string)
      use start_payload <- decode.optional_field(
        "start_payload",
        None,
        decode.optional(decode.string),
      )
      decode.success(MessageChatCreated(
        timestamp:,
        chat:,
        message_id:,
        start_payload:,
      ))
    }
    other ->
      decode.failure(
        MessageRemoved(
          timestamp: 0,
          message_id: "",
          chat_id: 0,
          user_id: 0,
        ),
        "Update: unknown update_type " <> other,
      )
  }
}
