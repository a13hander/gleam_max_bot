import envoy

pub type Config {
  Config(token: String)
}

pub fn from_token(token: String) -> Config {
  Config(token:)
}

pub fn load() -> Config {
  let assert Ok(token) = envoy.get("MAX_BOT_TOKEN")
  Config(token:)
}
