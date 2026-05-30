import gleam/dynamic/decode.{type Decoder}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/httpc
import gleam/json
import max_bot/config.{type Config}
import max_bot/error.{type Error}

pub fn base_request(config: Config, path: String) -> Request(String) {
  let domain = "https://botapi.max.ru"
  let assert Ok(base_req) = request.to(domain <> path)

  base_req
  |> request.prepend_header("content-type", "application/json")
  |> request.prepend_header("accept", "application/json")
  |> request.prepend_header("Authorization", config.token)
}

pub fn send(req: Request(String), decoder: Decoder(a)) -> Result(a, Error) {
  case httpc.send(req) {
    Ok(resp) -> handle(resp, decoder)
    Error(_) -> Error(error.NetworkError("HTTP request failed"))
  }
}

pub fn send_ignoring_body(req: Request(String)) -> Result(Nil, Error) {
  case httpc.send(req) {
    Ok(resp) ->
      case resp.status {
        200 -> Ok(Nil)
        _ -> Error(decode_api_error(resp))
      }
    Error(_) -> Error(error.NetworkError("HTTP request failed"))
  }
}

fn handle(resp: Response(String), decoder: Decoder(a)) -> Result(a, Error) {
  case resp.status {
    200 ->
      case json.parse(resp.body, decoder) {
        Ok(value) -> Ok(value)
        Error(err) -> Error(error.DecodeError(err))
      }
    _ -> Error(decode_api_error(resp))
  }
}

fn decode_api_error(resp: Response(String)) -> Error {
  case json.parse(resp.body, error_body_decoder()) {
    Ok(#(code, message)) ->
      error.ApiError(status: resp.status, code:, message:)
    Error(_) ->
      error.ApiError(status: resp.status, code: "unknown", message: resp.body)
  }
}

fn error_body_decoder() -> Decoder(#(String, String)) {
  use code <- decode.field("code", decode.string)
  use message <- decode.field("message", decode.string)
  decode.success(#(code, message))
}
