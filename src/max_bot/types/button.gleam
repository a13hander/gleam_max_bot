import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import gleam/option.{type Option, None, Some}

pub type Intent {
  Positive
  Negative
  Default
}

pub type Button {
  Callback(text: String, payload: String, intent: Intent)
  Link(text: String, url: String)
  RequestContact(text: String)
  RequestGeoLocation(text: String, quick: Bool)
  ChatButton(
    text: String,
    chat_title: String,
    chat_description: Option(String),
    start_payload: Option(String),
    uuid: Option(Int),
  )
  MessageButton(text: String)
}

pub fn callback(text text: String, payload payload: String) -> Button {
  Callback(text:, payload:, intent: Default)
}

pub fn callback_with_intent(
  text text: String,
  payload payload: String,
  intent intent: Intent,
) -> Button {
  Callback(text:, payload:, intent:)
}

pub fn link(text text: String, url url: String) -> Button {
  Link(text:, url:)
}

pub fn request_contact(text text: String) -> Button {
  RequestContact(text:)
}

pub fn request_geo_location(text text: String, quick quick: Bool) -> Button {
  RequestGeoLocation(text:, quick:)
}

pub fn intent_to_string(intent: Intent) -> String {
  case intent {
    Positive -> "positive"
    Negative -> "negative"
    Default -> "default"
  }
}

pub fn intent_decoder() -> Decoder(Intent) {
  use s <- decode.then(decode.string)
  case s {
    "positive" -> decode.success(Positive)
    "negative" -> decode.success(Negative)
    "default" -> decode.success(Default)
    other -> decode.failure(Default, "Intent: unknown variant " <> other)
  }
}

pub fn encode(button: Button) -> Json {
  case button {
    Callback(text:, payload:, intent:) ->
      json.object([
        #("type", json.string("callback")),
        #("text", json.string(text)),
        #("payload", json.string(payload)),
        #("intent", json.string(intent_to_string(intent))),
      ])
    Link(text:, url:) ->
      json.object([
        #("type", json.string("link")),
        #("text", json.string(text)),
        #("url", json.string(url)),
      ])
    RequestContact(text:) ->
      json.object([
        #("type", json.string("request_contact")),
        #("text", json.string(text)),
      ])
    RequestGeoLocation(text:, quick:) ->
      json.object([
        #("type", json.string("request_geo_location")),
        #("text", json.string(text)),
        #("quick", json.bool(quick)),
      ])
    ChatButton(text:, chat_title:, chat_description:, start_payload:, uuid:) ->
      json.object(
        [
          #("type", json.string("chat")),
          #("text", json.string(text)),
          #("chat_title", json.string(chat_title)),
        ]
        |> append_opt("chat_description", chat_description, json.string)
        |> append_opt("start_payload", start_payload, json.string)
        |> append_opt("uuid", uuid, json.int),
      )
    MessageButton(text:) ->
      json.object([
        #("type", json.string("message")),
        #("text", json.string(text)),
      ])
  }
}

fn append_opt(
  fields: List(#(String, Json)),
  key: String,
  value: Option(a),
  encode_value: fn(a) -> Json,
) -> List(#(String, Json)) {
  case value {
    Some(v) -> [#(key, encode_value(v)), ..fields]
    None -> fields
  }
}

pub fn decoder() -> Decoder(Button) {
  use type_ <- decode.field("type", decode.string)
  use text <- decode.field("text", decode.string)
  case type_ {
    "callback" -> {
      use payload <- decode.field("payload", decode.string)
      use intent <- decode.optional_field("intent", Default, intent_decoder())
      decode.success(Callback(text:, payload:, intent:))
    }
    "link" -> {
      use url <- decode.field("url", decode.string)
      decode.success(Link(text:, url:))
    }
    "request_contact" -> decode.success(RequestContact(text:))
    "request_geo_location" -> {
      use quick <- decode.optional_field("quick", False, decode.bool)
      decode.success(RequestGeoLocation(text:, quick:))
    }
    "chat" -> {
      use chat_title <- decode.field("chat_title", decode.string)
      use chat_description <- decode.optional_field(
        "chat_description",
        None,
        decode.optional(decode.string),
      )
      use start_payload <- decode.optional_field(
        "start_payload",
        None,
        decode.optional(decode.string),
      )
      use uuid <- decode.optional_field(
        "uuid",
        None,
        decode.optional(decode.int),
      )
      decode.success(ChatButton(
        text:,
        chat_title:,
        chat_description:,
        start_payload:,
        uuid:,
      ))
    }
    "message" -> decode.success(MessageButton(text:))
    other ->
      decode.failure(MessageButton(text:), "Button: unknown type " <> other)
  }
}
