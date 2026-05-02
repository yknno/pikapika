import gleam/list
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/element/keyed
import lustre/event

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

type Model =
  List(String)

fn init(_) -> Model {
  ["8le", "bm2", "8pg", "9ev", "9pm", "oc"]
}

type Message {
  UserClickedCycle
}

fn update(model: Model, message: Message) -> Model {
  case message {
    UserClickedCycle ->
      case model {
        [head, ..rest] -> list.append(rest, [head])
        [] -> []
      }
  }
}

fn view(model: Model) -> Element(Message) {
  let images = list.take(model, 3)

  html.div([attribute.class("w-full max-w-2xl mx-auto flex flex-col gap-4")], [
    view_unkeyed_list(images),
    view_keyed_list(images),
    html.button(
      [
        event.on_click(UserClickedCycle),
        attribute.class("w-full bg-orange-500 text-white py-1 rounded"),
      ],
      [html.text("Next")],
    ),
  ])
}

fn view_unkeyed_list(images: List(String)) -> Element(message) {
  html.div([], [
    html.h2([attribute.class("text-2xl py-2")], [html.text("Unkeyed")]),
    html.ul([attribute.class("grid grid-cols-3 gap-2")], {
      list.map(images, view_cat)
    }),
  ])
}

fn view_keyed_list(images: List(String)) -> Element(message) {
  html.div([], [
    html.h2([attribute.class("text-2xl py-2")], [html.text("Keyed")]),
    keyed.ul([attribute.class("grid grid-cols-3 gap-2")], {
      list.map(images, fn(id) { #(id, view_cat(id)) })
    }),
  ])
}

fn view_cat(id: String) -> Element(message) {
  html.img([
    attribute.class("aspect-square rounded"),
    attribute.src("https://cdn2.thecatapi.com/images/" <> id <> ".jpg"),
  ])
}
