import gleam/json

pub type Error {
  NetworkError(message: String)
  DecodeError(reason: json.DecodeError)
  ApiError(status: Int, code: String, message: String)
}
