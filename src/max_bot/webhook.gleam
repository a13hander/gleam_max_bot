import gleam/json
import max_bot/types/update.{type Update}

pub fn parse_update(body: String) -> Result(Update, json.DecodeError) {
  json.parse(body, update.decoder())
}
