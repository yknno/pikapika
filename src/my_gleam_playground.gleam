import gleam/int
import lustre
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub fn main() {
  let app = lustre.simple(init, update, view)

  let initial_count = int.random(20)
  let assert Ok(_) = lustre.start(app, "#app", initial_count)

  Nil
}

type Model = Int

fn init(initial_count) -> Model {
  initial_count / 2
}

type Message {
  UserClickedIncrement
  UserClickedDecrement
}

fn update(model: Model, message: Message) -> Model {
  case message {
    UserClickedIncrement -> model + 1
    UserClickedDecrement -> model - 1
  }
}

fn view(model: Model) -> Element(Message) {
  let count = int.to_string(model)

  html.div([], [
    html.button([event.on_click(UserClickedDecrement)], [html.text("-")]),
    html.p([], [html.text("Count: "), html.text(count)]),
    html.button([event.on_click(UserClickedIncrement)], [html.text("+")]),
  ])
}
