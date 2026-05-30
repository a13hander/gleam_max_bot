import gleam/dynamic/decode.{type Decoder}
import gleam/option.{type Option, None}
import max_bot/types/keyboard.{type Keyboard}
import max_bot/types/user.{type User}

pub type PhotoPayload {
  PhotoPayload(photo_id: Int, token: String, url: String)
}

pub type MediaPayload {
  MediaPayload(url: String, token: String)
}

pub type FilePayload {
  FilePayload(url: String, token: String)
}

pub type StickerPayload {
  StickerPayload(url: String, code: String)
}

pub type ContactPayload {
  ContactPayload(vcf_info: Option(String), max_info: Option(User))
}

pub type SharePayload {
  SharePayload(url: Option(String), token: Option(String))
}

pub type VideoThumbnail {
  VideoThumbnail(url: String)
}

pub type Attachment {
  Image(payload: PhotoPayload)
  Video(
    payload: MediaPayload,
    thumbnail: Option(VideoThumbnail),
    width: Option(Int),
    height: Option(Int),
    duration: Option(Int),
  )
  Audio(payload: MediaPayload, transcription: Option(String))
  File(payload: FilePayload, filename: String, size: Int)
  Sticker(payload: StickerPayload, width: Int, height: Int)
  Contact(payload: ContactPayload)
  Share(
    payload: SharePayload,
    title: Option(String),
    description: Option(String),
    image_url: Option(String),
  )
  Location(latitude: Float, longitude: Float)
  InlineKeyboardAttachment(payload: Keyboard)
  ReplyKeyboardAttachment
  Data(data: String)
}

fn photo_payload_decoder() -> Decoder(PhotoPayload) {
  use photo_id <- decode.field("photo_id", decode.int)
  use token <- decode.field("token", decode.string)
  use url <- decode.field("url", decode.string)
  decode.success(PhotoPayload(photo_id:, token:, url:))
}

fn media_payload_decoder() -> Decoder(MediaPayload) {
  use url <- decode.field("url", decode.string)
  use token <- decode.field("token", decode.string)
  decode.success(MediaPayload(url:, token:))
}

fn file_payload_decoder() -> Decoder(FilePayload) {
  use url <- decode.field("url", decode.string)
  use token <- decode.field("token", decode.string)
  decode.success(FilePayload(url:, token:))
}

fn sticker_payload_decoder() -> Decoder(StickerPayload) {
  use url <- decode.field("url", decode.string)
  use code <- decode.field("code", decode.string)
  decode.success(StickerPayload(url:, code:))
}

fn contact_payload_decoder() -> Decoder(ContactPayload) {
  use vcf_info <- decode.optional_field(
    "vcf_info",
    None,
    decode.optional(decode.string),
  )
  use max_info <- decode.optional_field(
    "max_info",
    None,
    decode.optional(user.user_decoder()),
  )
  decode.success(ContactPayload(vcf_info:, max_info:))
}

fn share_payload_decoder() -> Decoder(SharePayload) {
  use url <- decode.optional_field(
    "url",
    None,
    decode.optional(decode.string),
  )
  use token <- decode.optional_field(
    "token",
    None,
    decode.optional(decode.string),
  )
  decode.success(SharePayload(url:, token:))
}

fn video_thumbnail_decoder() -> Decoder(VideoThumbnail) {
  use url <- decode.field("url", decode.string)
  decode.success(VideoThumbnail(url:))
}

pub fn decoder() -> Decoder(Attachment) {
  use type_ <- decode.field("type", decode.string)
  case type_ {
    "image" -> {
      use payload <- decode.field("payload", photo_payload_decoder())
      decode.success(Image(payload:))
    }
    "video" -> {
      use payload <- decode.field("payload", media_payload_decoder())
      use thumbnail <- decode.optional_field(
        "thumbnail",
        None,
        decode.optional(video_thumbnail_decoder()),
      )
      use width <- decode.optional_field(
        "width",
        None,
        decode.optional(decode.int),
      )
      use height <- decode.optional_field(
        "height",
        None,
        decode.optional(decode.int),
      )
      use duration <- decode.optional_field(
        "duration",
        None,
        decode.optional(decode.int),
      )
      decode.success(Video(payload:, thumbnail:, width:, height:, duration:))
    }
    "audio" -> {
      use payload <- decode.field("payload", media_payload_decoder())
      use transcription <- decode.optional_field(
        "transcription",
        None,
        decode.optional(decode.string),
      )
      decode.success(Audio(payload:, transcription:))
    }
    "file" -> {
      use payload <- decode.field("payload", file_payload_decoder())
      use filename <- decode.field("filename", decode.string)
      use size <- decode.field("size", decode.int)
      decode.success(File(payload:, filename:, size:))
    }
    "sticker" -> {
      use payload <- decode.field("payload", sticker_payload_decoder())
      use width <- decode.field("width", decode.int)
      use height <- decode.field("height", decode.int)
      decode.success(Sticker(payload:, width:, height:))
    }
    "contact" -> {
      use payload <- decode.field("payload", contact_payload_decoder())
      decode.success(Contact(payload:))
    }
    "share" -> {
      use payload <- decode.field("payload", share_payload_decoder())
      use title <- decode.optional_field(
        "title",
        None,
        decode.optional(decode.string),
      )
      use description <- decode.optional_field(
        "description",
        None,
        decode.optional(decode.string),
      )
      use image_url <- decode.optional_field(
        "image_url",
        None,
        decode.optional(decode.string),
      )
      decode.success(Share(payload:, title:, description:, image_url:))
    }
    "location" -> {
      use latitude <- decode.field("latitude", decode.float)
      use longitude <- decode.field("longitude", decode.float)
      decode.success(Location(latitude:, longitude:))
    }
    "inline_keyboard" -> {
      use payload <- decode.field("payload", keyboard.decoder())
      decode.success(InlineKeyboardAttachment(payload:))
    }
    "reply_keyboard" -> decode.success(ReplyKeyboardAttachment)
    "data" -> {
      use data <- decode.field("data", decode.string)
      decode.success(Data(data:))
    }
    other -> decode.failure(ReplyKeyboardAttachment, "Attachment: unknown type " <> other)
  }
}
