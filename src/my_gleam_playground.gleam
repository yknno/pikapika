import gleam/list
import gleam/set.{type Set}
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

type Model {
  Model(open: Set(String), entries: List(#(String, String)))
}

fn init(_) -> Model {
  let entries = [
    #("Foo", "Test Text head."),
    #("Bar", "あいうえお。"),
    #("Xxx", "1234567890"),
  ]

  Model(open: set.new(), entries:)
}

type Message {
  UserToggledEntry(String)
}

fn update(model: Model, message: Message) -> Model {
  case message {
    UserToggledEntry(id) ->
      case set.contains(model.open, id) {
        True -> Model(..model, open: set.delete(model.open, id))
        False -> Model(..model, open: set.insert(model.open, id))
      }
  }
}

fn view(model: Model) -> Element(Message) {
  html.div([attribute.class("p-32 w-full max-w-2xl mx-auto space-y-4")], [
    html.h1([attribute.class("text-2xl font-semibold")], [html.text("FAQ")]),
    keyed.fragment(list.map(model.entries, view_entry(model.open, _))),
    html.p([], [
      html.text(
        "Open your browser dev tools now to see how the final HTML looks like!",
      ),
    ]),
  ])
}

fn view_entry(
  open: Set(String),
  entry: #(String, String),
) -> #(String, Element(Message)) {
  let #(question, answer) = entry
  let is_open = set.contains(open, question)

  let html =
    element.fragment([
      html.button(
        [
          attribute.class("block w-full px-4 py-2 text-lg border rounded-lg"),
          event.on_click(UserToggledEntry(question)),
        ],
        [
          html.text(question),
          html.span(
            [
              attribute.class(
                "inline-block ml-4 text-2xl leading-none align-middle transform transition-transform",
              ),
              case is_open {
                True -> attribute.class("rotate-90")
                False -> attribute.class("-rotate-90")
              },
            ],
            [html.text("›")],
          ),
        ],
      ),
      case is_open {
        True ->
          html.p([attribute.class("bg-gray-100 p-4 rounded-lg shadow-inset")], [
            html.text(answer),
          ])
        False -> element.none()
      },
    ])

  #(question, html)
}
