import gleam/dynamic/decode.{type Decoder}
import gleam/option.{type Option, None}
import max_bot/types/attachment.{type Attachment}
import max_bot/types/chat.{type ChatType}
import max_bot/types/user.{type User}

pub type MessageLinkType {
  Forward
  Reply
}

pub type TextFormat {
  Markdown
  Html
}

pub type Recipient {
  Recipient(
    chat_id: Option(Int),
    chat_type: ChatType,
    user_id: Option(Int),
  )
}

pub type MessageStat {
  MessageStat(views: Int)
}

pub type MessageBody {
  MessageBody(
    mid: String,
    seq: Int,
    text: Option(String),
    attachments: Option(List(Attachment)),
  )
}

pub type LinkedMessage {
  LinkedMessage(
    link_type: MessageLinkType,
    sender: Option(User),
    chat_id: Option(Int),
    message: MessageBody,
  )
}

pub type Message {
  Message(
    sender: Option(User),
    recipient: Recipient,
    timestamp: Int,
    link: Option(LinkedMessage),
    body: MessageBody,
    stat: Option(MessageStat),
    url: Option(String),
  )
}

pub fn message_link_type_decoder() -> Decoder(MessageLinkType) {
  use s <- decode.then(decode.string)
  case s {
    "forward" -> decode.success(Forward)
    "reply" -> decode.success(Reply)
    other ->
      decode.failure(Reply, "MessageLinkType: unknown variant " <> other)
  }
}

pub fn text_format_decoder() -> Decoder(TextFormat) {
  use s <- decode.then(decode.string)
  case s {
    "markdown" -> decode.success(Markdown)
    "html" -> decode.success(Html)
    other -> decode.failure(Markdown, "TextFormat: unknown variant " <> other)
  }
}

pub fn text_format_to_string(format: TextFormat) -> String {
  case format {
    Markdown -> "markdown"
    Html -> "html"
  }
}

pub fn message_link_type_to_string(t: MessageLinkType) -> String {
  case t {
    Forward -> "forward"
    Reply -> "reply"
  }
}

pub fn recipient_decoder() -> Decoder(Recipient) {
  use chat_id <- decode.optional_field(
    "chat_id",
    None,
    decode.optional(decode.int),
  )
  use chat_type <- decode.field("chat_type", chat.chat_type_decoder())
  use user_id <- decode.optional_field(
    "user_id",
    None,
    decode.optional(decode.int),
  )
  decode.success(Recipient(chat_id:, chat_type:, user_id:))
}

pub fn message_stat_decoder() -> Decoder(MessageStat) {
  use views <- decode.field("views", decode.int)
  decode.success(MessageStat(views:))
}

pub fn message_body_decoder() -> Decoder(MessageBody) {
  use mid <- decode.field("mid", decode.string)
  use seq <- decode.field("seq", decode.int)
  use text <- decode.optional_field(
    "text",
    None,
    decode.optional(decode.string),
  )
  use attachments <- decode.optional_field(
    "attachments",
    None,
    decode.optional(decode.list(attachment.decoder())),
  )
  decode.success(MessageBody(mid:, seq:, text:, attachments:))
}

pub fn linked_message_decoder() -> Decoder(LinkedMessage) {
  use link_type <- decode.field("type", message_link_type_decoder())
  use sender <- decode.optional_field(
    "sender",
    None,
    decode.optional(user.user_decoder()),
  )
  use chat_id <- decode.optional_field(
    "chat_id",
    None,
    decode.optional(decode.int),
  )
  use message <- decode.field("message", message_body_decoder())
  decode.success(LinkedMessage(link_type:, sender:, chat_id:, message:))
}

pub fn message_decoder() -> Decoder(Message) {
  use sender <- decode.optional_field(
    "sender",
    None,
    decode.optional(user.user_decoder()),
  )
  use recipient <- decode.field("recipient", recipient_decoder())
  use timestamp <- decode.field("timestamp", decode.int)
  use link <- decode.optional_field(
    "link",
    None,
    decode.optional(linked_message_decoder()),
  )
  use body <- decode.field("body", message_body_decoder())
  use stat <- decode.optional_field(
    "stat",
    None,
    decode.optional(message_stat_decoder()),
  )
  use url <- decode.optional_field(
    "url",
    None,
    decode.optional(decode.string),
  )
  decode.success(Message(
    sender:,
    recipient:,
    timestamp:,
    link:,
    body:,
    stat:,
    url:,
  ))
}
