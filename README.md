# max_bot

Gleam client for the [Max Bot API](https://dev.max.ru/docs-api). Covers sending text messages with inline keyboards, replying to button presses, and parsing incoming webhook updates.

## What's included

- Send messages (`POST /messages`): text, text + inline keyboard, via the `NewMessageBody` builder
- Reply to inline button presses (`POST /answers`): notification or message replacement
- Fetch bot info (`GET /me`)
- Parse a webhook request body into a typed `Update` (all 11 variants: `MessageCreated`, `MessageCallback`, `MessageEdited`, `MessageRemoved`, `BotAdded`, `BotRemoved`, `UserAdded`, `UserRemoved`, `BotStarted`, `ChatTitleChanged`, `MessageChatCreated`)
- Full typing for incoming attachments (image, video, audio, file, sticker, contact, share, location, inline/reply keyboard, data)

Out of scope (can be added later): media upload (`POST /uploads`), chat and member management, webhook subscription endpoints, message editing/deletion, text markup elements.

## Installation

### Local development (path dependency)

In the consumer's `gleam.toml`:

```toml
[dependencies]
max_bot = { path = "../max_bot" }
```

### From a git repository

```toml
[dependencies]
max_bot = { git = "https://github.com/USER/max_bot.git", ref = "main" }
```

Then `gleam deps download`.

## Usage

```gleam
import max_bot/api/answers
import max_bot/api/messages
import max_bot/config
import max_bot/types/button
import max_bot/types/callback
import max_bot/types/keyboard
import max_bot/types/update
import max_bot/webhook

pub fn handle_webhook(body: String, token: String) {
  let cfg = config.from_token(token)

  case webhook.parse_update(body) {
    Ok(update.MessageCreated(message:, ..)) -> {
      let assert Some(chat_id) = message.recipient.chat_id
      let kbd =
        keyboard.new([
          [
            button.callback(text: "Yes", payload: "yes"),
            button.callback(text: "No", payload: "no"),
          ],
        ])
      messages.send_keyboard(cfg, messages.Chat(id: chat_id), "reply?", kbd)
    }

    Ok(update.MessageCallback(callback: cb, ..)) ->
      answers.answer(cfg, cb.callback_id, callback.notify("got it"))

    Ok(_) -> Ok(todo)
    Error(_) -> Error(todo)
  }
}
```

### Configuration

Two ways to construct a `Config`:

```gleam
config.from_token("your-token")   // explicit
config.load()                     // from MAX_BOT_TOKEN env var
```

### Authentication

The token is sent in the `Authorization` HTTP header as a raw value (no `Bearer` prefix). The `botapi.max.ru` server explicitly rejects `?access_token=` query (despite the OpenAPI spec still listing query as canonical) and the `Bearer` scheme. Verified against live `/me`.

## Project structure

```
src/max_bot/
  config.gleam            Config construction
  client.gleam            HTTP wrapper, parses {code, message} into ApiError
  error.gleam             Error (NetworkError | DecodeError | ApiError)
  types/
    user.gleam            User, UserWithPhoto, BotInfo
    chat.gleam            Chat, ChatType, ChatStatus
    button.gleam          Button (callback/link/request_contact/request_geo_location/chat/message)
    keyboard.gleam        Keyboard
    attachment.gleam      Attachment (11 incoming variants)
    message.gleam         Message, MessageBody, LinkedMessage, Recipient
    new_message.gleam     NewMessageBody with builder (with_keyboard/with_format/with_notify/with_link)
    callback.gleam        Callback, CallbackAnswer
    update.gleam          Update (11 variants)
  api/
    me.gleam              GET /me
    messages.gleam        POST /messages
    answers.gleam         POST /answers
  webhook.gleam           parse_update(body) — entry point for the webhook receiver
```

## Development

```sh
gleam build   # build
gleam test    # tests (no network calls)
```
