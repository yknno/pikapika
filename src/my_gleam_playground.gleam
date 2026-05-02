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
  Model(name: String, x: Int, y: Int)
}

fn init(_) -> Model {
  Model(name: "Lucy", x: 0, y: 0)
}

type Message {
  UserUpdateName(String)
  UserMovedMouse(x: Int, y: Int)
}

fn update(model: Model, message: Message) -> Model {
  case message {
    UserUpdateName(name) -> Model(..model, name:)
    UserMovedMouse(x:, y:) -> Model(..model, x:, y:)
  }
}

fn view(model: Model) -> Element(Message) {
  html.div([attribute.class("p-32 mx-auto w-full max-w-2x1 space-y-8")], [
    view_debounced_input(name: model.name, on_input: UserUpdateName),
    view_xy_pad(x: model.x, y: model.y, on_mousemove: UserMovedMouse),
  ])
}

fn view_debounced_input(
  name name: String,
  on_input handle_input: fn(String) -> message,
) -> Element(message) {
  html.div([attribute.class("space-y-2")], [
    html.label([attribute.class("flex gap-2")], [
      html.span([], [html.text("Enter a name:")]),
      html.input([
        attribute.value(name),
        event.on_input(handle_input) |> event.debounce(500),
        attribute.class("border border-slate-400 px-1 rounded"),
        attribute.class("focus:outline-none focus:border-blue-500"),
      ])
    ]),
    html.p([], [html.text("Hello there, "), html.text(name), html.text("!")]),
  ])
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
      // on_mousemove |> event.throttle(250),
      on_mousemove |> event.debounce(250),
      attribute.class("flex justify-center items-center"),
      attribute.class("aspect-square bg-slate-100 rounded hover:shadow"),
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
