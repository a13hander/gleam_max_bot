import gleam/dynamic/decode.{type Decoder}
import gleam/http
import gleam/http/request
import gleam/int
import gleam/json
import max_bot/client
import max_bot/config.{type Config}
import max_bot/error.{type Error}
import max_bot/types/keyboard.{type Keyboard}
import max_bot/types/message.{type Message}
import max_bot/types/new_message.{type NewMessageBody}

pub type Target {
  Chat(id: Int)
  User(id: Int)
}

pub fn send(
  config: Config,
  target: Target,
  body: NewMessageBody,
) -> Result(Message, Error) {
  client.base_request(config, "/messages")
  |> request.set_method(http.Post)
  |> append_target_query(target)
  |> request.set_body(json.to_string(new_message.encode(body)))
  |> client.send(send_result_decoder())
}

pub fn send_text(
  config: Config,
  target: Target,
  text: String,
) -> Result(Message, Error) {
  send(config, target, new_message.text(text))
}

pub fn send_keyboard(
  config: Config,
  target: Target,
  text: String,
  keyboard: Keyboard,
) -> Result(Message, Error) {
  send(
    config,
    target,
    new_message.text(text) |> new_message.with_keyboard(keyboard),
  )
}

fn append_target_query(req, target: Target) {
  let pair = case target {
    Chat(id:) -> #("chat_id", int.to_string(id))
    User(id:) -> #("user_id", int.to_string(id))
  }
  request.set_query(req, [pair])
}

fn send_result_decoder() -> Decoder(Message) {
  use msg <- decode.field("message", message.message_decoder())
  decode.success(msg)
}
