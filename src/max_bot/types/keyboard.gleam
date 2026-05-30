import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import max_bot/types/button.{type Button}

pub type Keyboard {
  Keyboard(buttons: List(List(Button)))
}

pub fn new(rows: List(List(Button))) -> Keyboard {
  Keyboard(buttons: rows)
}

pub fn encode(keyboard: Keyboard) -> Json {
  let Keyboard(buttons:) = keyboard
  json.object([
    #("buttons", json.array(buttons, json.array(_, button.encode))),
  ])
}

pub fn decoder() -> Decoder(Keyboard) {
  use buttons <- decode.field(
    "buttons",
    decode.list(decode.list(button.decoder())),
  )
  decode.success(Keyboard(buttons:))
}
