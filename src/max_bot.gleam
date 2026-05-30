//// Gleam client for the Max Bot API.
////
//// Entry points:
//// - `max_bot/config` — construct a `Config` with the bot token
//// - `max_bot/api/messages` — send messages (text, inline keyboard)
//// - `max_bot/api/answers` — reply to inline button presses
//// - `max_bot/api/me` — bot information
//// - `max_bot/webhook` — parse `Update` from a webhook request body
////
//// Types:
//// - `max_bot/types/update` — `Update` (11 event variants)
//// - `max_bot/types/message` — `Message`, `MessageBody`, `Recipient`
//// - `max_bot/types/new_message` — `NewMessageBody` with builder
//// - `max_bot/types/keyboard`, `max_bot/types/button` — inline keyboards
//// - `max_bot/types/callback` — `Callback`, `CallbackAnswer`
//// - `max_bot/types/attachment` — incoming message attachments
//// - `max_bot/types/user`, `max_bot/types/chat`
//// - `max_bot/error` — `Error` (`NetworkError`, `DecodeError`, `ApiError`)

pub const version = "0.1.0"
