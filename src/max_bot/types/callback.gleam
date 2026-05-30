import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import gleam/option.{type Option, None, Some}
import max_bot/types/new_message.{type NewMessageBody}
import max_bot/types/user.{type User}

pub type Callback {
  Callback(
    timestamp: Int,
    callback_id: String,
    payload: Option(String),
    user: User,
  )
}

pub type CallbackAnswer {
  CallbackAnswer(message: Option(NewMessageBody), notification: Option(String))
}

pub fn notify(text: String) -> CallbackAnswer {
  CallbackAnswer(message: None, notification: Some(text))
}

pub fn replace_message(body: NewMessageBody) -> CallbackAnswer {
  CallbackAnswer(message: Some(body), notification: None)
}

pub fn callback_decoder() -> Decoder(Callback) {
  use timestamp <- decode.field("timestamp", decode.int)
  use callback_id <- decode.field("callback_id", decode.string)
  use payload <- decode.optional_field(
    "payload",
    None,
    decode.optional(decode.string),
  )
  use user <- decode.field("user", user.user_decoder())
  decode.success(Callback(timestamp:, callback_id:, payload:, user:))
}

pub fn encode_answer(answer: CallbackAnswer) -> Json {
  let CallbackAnswer(message:, notification:) = answer
  let fields = case message {
    Some(m) -> [#("message", new_message.encode(m))]
    None -> []
  }
  let fields = case notification {
    Some(n) -> [#("notification", json.string(n)), ..fields]
    None -> fields
  }
  json.object(fields)
}
