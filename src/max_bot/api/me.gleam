import max_bot/client
import max_bot/config.{type Config}
import max_bot/error.{type Error}
import max_bot/types/user.{type BotInfo}

pub fn me(config: Config) -> Result(BotInfo, Error) {
  client.base_request(config, "/me")
  |> client.send(user.bot_info_decoder())
}
