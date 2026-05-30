import gleam/dynamic/decode.{type Decoder}
import gleam/option.{type Option, None}

pub type ChatType {
  ChatGroup
  Channel
  Dialog
}

pub type ChatStatus {
  Active
  Removed
  Left
  Closed
}

pub type Image {
  Image(url: String)
}

pub type Chat {
  Chat(
    chat_id: Int,
    chat_type: ChatType,
    status: ChatStatus,
    title: Option(String),
    icon: Option(Image),
    last_event_time: Int,
    participants_count: Int,
    owner_id: Option(Int),
    is_public: Bool,
    link: Option(String),
    description: Option(String),
    messages_count: Option(Int),
    chat_message_id: Option(String),
  )
}

pub fn chat_type_decoder() -> Decoder(ChatType) {
  use s <- decode.then(decode.string)
  case s {
    "chat" -> decode.success(ChatGroup)
    "channel" -> decode.success(Channel)
    "dialog" -> decode.success(Dialog)
    other -> decode.failure(ChatGroup, "ChatType: unknown variant " <> other)
  }
}

pub fn chat_status_decoder() -> Decoder(ChatStatus) {
  use s <- decode.then(decode.string)
  case s {
    "active" -> decode.success(Active)
    "removed" -> decode.success(Removed)
    "left" -> decode.success(Left)
    "closed" -> decode.success(Closed)
    other -> decode.failure(Active, "ChatStatus: unknown variant " <> other)
  }
}

pub fn image_decoder() -> Decoder(Image) {
  use url <- decode.field("url", decode.string)
  decode.success(Image(url:))
}

pub fn chat_decoder() -> Decoder(Chat) {
  use chat_id <- decode.field("chat_id", decode.int)
  use chat_type <- decode.field("type", chat_type_decoder())
  use status <- decode.field("status", chat_status_decoder())
  use title <- decode.optional_field(
    "title",
    None,
    decode.optional(decode.string),
  )
  use icon <- decode.optional_field(
    "icon",
    None,
    decode.optional(image_decoder()),
  )
  use last_event_time <- decode.field("last_event_time", decode.int)
  use participants_count <- decode.field("participants_count", decode.int)
  use owner_id <- decode.optional_field(
    "owner_id",
    None,
    decode.optional(decode.int),
  )
  use is_public <- decode.field("is_public", decode.bool)
  use link <- decode.optional_field(
    "link",
    None,
    decode.optional(decode.string),
  )
  use description <- decode.optional_field(
    "description",
    None,
    decode.optional(decode.string),
  )
  use messages_count <- decode.optional_field(
    "messages_count",
    None,
    decode.optional(decode.int),
  )
  use chat_message_id <- decode.optional_field(
    "chat_message_id",
    None,
    decode.optional(decode.string),
  )
  decode.success(Chat(
    chat_id:,
    chat_type:,
    status:,
    title:,
    icon:,
    last_event_time:,
    participants_count:,
    owner_id:,
    is_public:,
    link:,
    description:,
    messages_count:,
    chat_message_id:,
  ))
}
