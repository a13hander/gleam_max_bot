import gleam/dynamic/decode.{type Decoder}
import gleam/option.{type Option, None}

pub type User {
  User(
    user_id: Int,
    first_name: String,
    last_name: Option(String),
    username: Option(String),
    is_bot: Bool,
    last_activity_time: Int,
    name: Option(String),
  )
}

pub type UserWithPhoto {
  UserWithPhoto(
    user: User,
    description: Option(String),
    avatar_url: Option(String),
    full_avatar_url: Option(String),
  )
}

pub type BotCommand {
  BotCommand(name: String, description: Option(String))
}

pub type BotInfo {
  BotInfo(user: UserWithPhoto, commands: Option(List(BotCommand)))
}

pub fn user_decoder() -> Decoder(User) {
  use user_id <- decode.field("user_id", decode.int)
  use first_name <- decode.field("first_name", decode.string)
  use last_name <- decode.optional_field(
    "last_name",
    None,
    decode.optional(decode.string),
  )
  use username <- decode.optional_field(
    "username",
    None,
    decode.optional(decode.string),
  )
  use is_bot <- decode.field("is_bot", decode.bool)
  use last_activity_time <- decode.optional_field(
    "last_activity_time",
    0,
    decode.int,
  )
  use name <- decode.optional_field(
    "name",
    None,
    decode.optional(decode.string),
  )
  decode.success(User(
    user_id:,
    first_name:,
    last_name:,
    username:,
    is_bot:,
    last_activity_time:,
    name:,
  ))
}

pub fn user_with_photo_decoder() -> Decoder(UserWithPhoto) {
  use user <- decode.then(user_decoder())
  use description <- decode.optional_field(
    "description",
    None,
    decode.optional(decode.string),
  )
  use avatar_url <- decode.optional_field(
    "avatar_url",
    None,
    decode.optional(decode.string),
  )
  use full_avatar_url <- decode.optional_field(
    "full_avatar_url",
    None,
    decode.optional(decode.string),
  )
  decode.success(UserWithPhoto(
    user:,
    description:,
    avatar_url:,
    full_avatar_url:,
  ))
}

fn bot_command_decoder() -> Decoder(BotCommand) {
  use name <- decode.field("name", decode.string)
  use description <- decode.optional_field(
    "description",
    None,
    decode.optional(decode.string),
  )
  decode.success(BotCommand(name:, description:))
}

pub fn bot_info_decoder() -> Decoder(BotInfo) {
  use user <- decode.then(user_with_photo_decoder())
  use commands <- decode.optional_field(
    "commands",
    None,
    decode.optional(decode.list(bot_command_decoder())),
  )
  decode.success(BotInfo(user:, commands:))
}
