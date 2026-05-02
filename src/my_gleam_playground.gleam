import gleam/dynamic/decode
import gleam/int
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

type Model {
  Model(x: Int, y: Int)
}

fn init(_) -> Model {
  Model(x: 0, y: 0)
}

type Message {
  UserMovedMouse(x: Int, y: Int)
}

fn update(_, message: Message) -> Model {
  case message {
    UserMovedMouse(x:, y:) -> Model(x:, y:)
  }
}

fn view(model: Model) -> Element(Message) {
  html.div(
    [attribute.class("w-screen h-screen flex justify-center items-center")],
    [view_xy_pad(x: model.x, y: model.y, on_mousemove: UserMovedMouse)],
  )
}

fn view_xy_pad(
  x x: Int,
  y y: Int,
  on_mousemove handle_mousemove: fn(Int, Int) -> message,
) -> Element(message) {
  let on_mousemove =
    event.on("mousemove", {
      use x <- decode.field("offsetX", decode.int)
      use y <- decode.field("offsetY", decode.int)

      decode.success(handle_mousemove(x, y))
    })

  html.div(
    [
      on_mousemove,
      attribute.class("flex justify-center items-center"),
      attribute.class("size-64 bg-slate-100 rounded hover:shadow"),
    ],
    [
      html.p([attribute.class("font-mono font-semibold text-slate-400")], [
        html.text("x: "),
        html.text(int.to_string(x)),
        html.text(", y: "),
        html.text(int.to_string(y)),
      ]),
    ],
  )
}
