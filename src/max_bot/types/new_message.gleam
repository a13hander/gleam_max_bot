import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import gleam/option.{type Option, None, Some}
import max_bot/types/keyboard.{type Keyboard}
import max_bot/types/message.{type MessageLinkType, type TextFormat}

pub type AttachmentRequest {
  InlineKeyboardRequest(payload: Keyboard)
}

pub type NewMessageLink {
  NewMessageLink(link_type: MessageLinkType, mid: String)
}

pub type NewMessageBody {
  NewMessageBody(
    text: Option(String),
    attachments: Option(List(AttachmentRequest)),
    link: Option(NewMessageLink),
    notify: Option(Bool),
    format: Option(TextFormat),
  )
}

pub fn text(s: String) -> NewMessageBody {
  NewMessageBody(
    text: Some(s),
    attachments: None,
    link: None,
    notify: None,
    format: None,
  )
}

pub fn with_keyboard(body: NewMessageBody, keyboard: Keyboard) -> NewMessageBody {
  NewMessageBody(
    ..body,
    attachments: Some([InlineKeyboardRequest(payload: keyboard)]),
  )
}

pub fn with_format(body: NewMessageBody, format: TextFormat) -> NewMessageBody {
  NewMessageBody(..body, format: Some(format))
}

pub fn with_notify(body: NewMessageBody, notify: Bool) -> NewMessageBody {
  NewMessageBody(..body, notify: Some(notify))
}

pub fn with_link(body: NewMessageBody, link: NewMessageLink) -> NewMessageBody {
  NewMessageBody(..body, link: Some(link))
}

pub fn reply_to(mid: String) -> NewMessageLink {
  NewMessageLink(link_type: message.Reply, mid:)
}

pub fn forward(mid: String) -> NewMessageLink {
  NewMessageLink(link_type: message.Forward, mid:)
}

pub fn encode_attachment_request(req: AttachmentRequest) -> Json {
  case req {
    InlineKeyboardRequest(payload:) ->
      json.object([
        #("type", json.string("inline_keyboard")),
        #("payload", keyboard.encode(payload)),
      ])
  }
}

pub fn encode_link(link: NewMessageLink) -> Json {
  let NewMessageLink(link_type:, mid:) = link
  json.object([
    #("type", json.string(message.message_link_type_to_string(link_type))),
    #("mid", json.string(mid)),
  ])
}

pub fn encode(body: NewMessageBody) -> Json {
  let NewMessageBody(text:, attachments:, link:, notify:, format:) = body
  let fields = [
    #("text", encode_nullable(text, json.string)),
    #(
      "attachments",
      encode_nullable(attachments, json.array(_, encode_attachment_request)),
    ),
    #("link", encode_nullable(link, encode_link)),
  ]
  let fields = case notify {
    Some(n) -> [#("notify", json.bool(n)), ..fields]
    None -> fields
  }
  let fields = case format {
    Some(f) -> [
      #("format", json.string(message.text_format_to_string(f))),
      ..fields
    ]
    None -> fields
  }
  json.object(fields)
}

fn encode_nullable(value: Option(a), encode: fn(a) -> Json) -> Json {
  case value {
    Some(v) -> encode(v)
    None -> json.null()
  }
}

pub fn new_message_link_decoder() -> Decoder(NewMessageLink) {
  use link_type <- decode.field("type", message.message_link_type_decoder())
  use mid <- decode.field("mid", decode.string)
  decode.success(NewMessageLink(link_type:, mid:))
}
