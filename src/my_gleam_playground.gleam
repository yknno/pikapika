// import formal/form.{type Form}
import gleam/list
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
  Model(todos: List(TodoItem), new_todo: String)
}

type TodoItem {
  TodoItem(text: String, done: Bool)
}

type Message {
  UserToggledTodo(index: Int)
  UserUpdatedInput(text: String)
  UserSubmitForm
}

fn init(_) -> Model {
  Model(
    todos: [
      TodoItem(text: "one", done: False),
      TodoItem(text: "two", done: False),
      TodoItem(text: "three", done: True),
    ],
    new_todo: "",
  )
}

fn update(model: Model, message: Message) -> Model {
  case message {
    UserToggledTodo(target) -> {
      let new_todos =
        list.index_map(model.todos, fn(todoitem, i) {
          case i == target {
            True -> TodoItem(..todoitem, done: !todoitem.done)
            False -> todoitem
          }
        })
      Model(..model, todos: new_todos)
    }
    UserUpdatedInput(text) -> {
      Model(..model, new_todo: text)
    }
    UserSubmitForm -> {
      case model.new_todo {
        "" -> model
        text -> Model(
          todos: list.append(model.todos, [TodoItem(text:, done: False)]),
          new_todo: ""
        )
      }
    }
  }
}

fn view(model: Model) -> Element(Message) {
  html.div([], [
    html.form([event.on_submit(fn(_) { UserSubmitForm })], [
      html.input([
        attribute.value(model.new_todo),
        event.on_input(UserUpdatedInput),
      ]),
      html.button([attribute.type_("submit")], [html.text("追加")]),
    ]),
    html.ul([], { list.index_map(model.todos, view_todo) })
  ])
}

fn view_todo(todoitem: TodoItem, index: Int) -> Element(Message) {
  html.div([], [
    case todoitem.done {
      True -> html.span([], [html.text("done")])
      False -> html.span([], [html.text("todo?")])
    },
    html.p([], [html.text(todoitem.text)]),
    html.input([
      attribute.type_("checkbox"),
      attribute.checked(todoitem.done),
      event.on_click(UserToggledTodo(index)),
    ]),
  ])
}
