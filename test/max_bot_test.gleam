import gleam/json
import gleam/option.{None, Some}
import gleeunit
import max_bot/types/button
import max_bot/types/callback
import max_bot/types/keyboard
import max_bot/types/new_message
import max_bot/types/update
import max_bot/webhook

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn encode_text_message_test() {
  let body = new_message.text("hello")
  let encoded = new_message.encode(body) |> json.to_string
  assert encoded == "{\"text\":\"hello\",\"attachments\":null,\"link\":null}"
}

pub fn encode_text_with_keyboard_test() {
  let kbd =
    keyboard.new([
      [button.callback(text: "Yes", payload: "yes")],
      [button.link(text: "Website", url: "https://example.com")],
    ])
  let body =
    new_message.text("choose:") |> new_message.with_keyboard(kbd)
  let encoded = new_message.encode(body) |> json.to_string
  let expected =
    "{\"text\":\"choose:\",\"attachments\":[{\"type\":\"inline_keyboard\","
    <> "\"payload\":{\"buttons\":[[{\"type\":\"callback\",\"text\":\"Yes\","
    <> "\"payload\":\"yes\",\"intent\":\"default\"}],[{\"type\":\"link\","
    <> "\"text\":\"Website\",\"url\":\"https://example.com\"}]]}}],\"link\":null}"
  assert encoded == expected
}

pub fn parse_message_created_test() {
  let body =
    "{
      \"update_type\": \"message_created\",
      \"timestamp\": 1700000000,
      \"message\": {
        \"sender\": {
          \"user_id\": 42,
          \"first_name\": \"Alice\",
          \"last_name\": null,
          \"username\": \"alice\",
          \"is_bot\": false,
          \"last_activity_time\": 1700000000000
        },
        \"recipient\": {
          \"chat_id\": 100,
          \"chat_type\": \"dialog\",
          \"user_id\": 42
        },
        \"timestamp\": 1700000000,
        \"body\": {
          \"mid\": \"mid-1\",
          \"seq\": 1,
          \"text\": \"hi bot\",
          \"attachments\": null
        }
      },
      \"user_locale\": \"en\"
    }"

  let assert Ok(update.MessageCreated(timestamp:, message:, user_locale:)) =
    webhook.parse_update(body)
  assert timestamp == 1700000000
  assert user_locale == Some("en")
  assert message.body.text == Some("hi bot")
  let assert Some(sender) = message.sender
  assert sender.first_name == "Alice"
}

pub fn parse_message_callback_test() {
  let body =
    "{
      \"update_type\": \"message_callback\",
      \"timestamp\": 1700000001,
      \"callback\": {
        \"timestamp\": 1700000001,
        \"callback_id\": \"cb-xyz\",
        \"payload\": \"yes\",
        \"user\": {
          \"user_id\": 42,
          \"first_name\": \"Alice\",
          \"last_name\": null,
          \"username\": \"alice\",
          \"is_bot\": false,
          \"last_activity_time\": 1700000001000
        }
      },
      \"message\": null
    }"

  let assert Ok(update.MessageCallback(callback: cb, message: msg, ..)) =
    webhook.parse_update(body)
  assert cb.callback_id == "cb-xyz"
  assert cb.payload == Some("yes")
  assert msg == None
}

pub fn answer_notify_encodes_test() {
  let answer = callback.notify("thanks!")
  let encoded = callback.encode_answer(answer) |> json.to_string
  assert encoded == "{\"notification\":\"thanks!\"}"
}

pub fn parse_bot_started_test() {
  let body =
    "{
      \"update_type\": \"bot_started\",
      \"timestamp\": 1700000002,
      \"chat_id\": 555,
      \"user\": {
        \"user_id\": 42,
        \"first_name\": \"Alice\",
        \"last_name\": null,
        \"username\": null,
        \"is_bot\": false,
        \"last_activity_time\": 1700000002000
      },
      \"payload\": \"deeplink-data\"
    }"

  let assert Ok(update.BotStarted(chat_id:, user:, payload:, ..)) =
    webhook.parse_update(body)
  assert chat_id == 555
  assert user.user_id == 42
  assert payload == Some("deeplink-data")
}
