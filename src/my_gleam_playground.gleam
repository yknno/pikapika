import gleam/string
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub fn main() -> Nil {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

type Model =
  String

fn init(_args) -> #(Model, Effect(Msg)) {
  let model = ""

  #(model, effect.none())
}

type Msg {
  UserUpdateText(String)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    UserUpdateText(txt) ->
      case string.length(txt) <= 10 {
        True -> #(txt, effect.none())
        False -> #(model, effect.none())
      }
  }
}

fn view(model: Model) -> Element(Msg) {
  html.div([], [
    html.div([], [
      html.input([
        attribute.value(model),
        event.on_input(UserUpdateText),
        attribute.name("foo"),
      ]),
    ]),

    html.div([], [
      html.text("Hello, "),
      html.text(model),
      html.text("!!!"),
    ]),
  ])
}
