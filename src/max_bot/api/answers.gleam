import gleam/http
import gleam/http/request
import gleam/json
import max_bot/client
import max_bot/config.{type Config}
import max_bot/error.{type Error}
import max_bot/types/callback.{type CallbackAnswer}

pub fn answer(
  config: Config,
  callback_id: String,
  body: CallbackAnswer,
) -> Result(Nil, Error) {
  client.base_request(config, "/answers")
  |> request.set_method(http.Post)
  |> request.set_query([#("callback_id", callback_id)])
  |> request.set_body(json.to_string(callback.encode_answer(body)))
  |> client.send_ignoring_body
}
