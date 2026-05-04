import formal/form.{type Form}
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
  Model(todos: List(TodoItem), form: Form(TodoInput))
}

type TodoInput {
  TodoInput(text: String)
}

type TodoItem {
  TodoItem(text: String, done: Bool)
}

type Message {
  UserToggledTodo(index: Int)
  UserSubmitForm(Result(TodoInput, Form(TodoInput)))
}

fn init(_) -> Model {
  Model(
    todos: [
      TodoItem(text: "one", done: False),
      TodoItem(text: "two", done: False),
      TodoItem(text: "three", done: True),
    ],
    form: new_form(),
  )
}

fn new_form() -> Form(TodoInput) {
  form.new({
    use text <- form.field("text", form.parse_string |> form.check_not_empty)

    form.success(TodoInput(text:))
  })
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
    UserSubmitForm(Ok(TodoInput(text:))) -> {
      Model(
        todos: list.append(model.todos, [TodoItem(text:, done: False)]),
        form: new_form(),
      )
    }
    UserSubmitForm(Error(form)) -> {
      Model(..model, form:)
    }
  }
}

fn view(model: Model) -> Element(Message) {
  html.div([], [
    view_todo_form(model.form),
    html.ul([], { list.index_map(model.todos, view_todo) }),
  ])
}

fn view_todo_form(form_state: Form(TodoInput)) -> Element(Message) {
  let handle_submit = fn(values) {
    form_state
    |> form.add_values(values)
    |> form.run
    |> UserSubmitForm
  }

  let errors = form.field_error_messages(form_state, "text")

  html.form([event.on_submit(handle_submit)], [
    html.input([
      attribute.id("text"),
      attribute.name("text"),
      attribute.value(form.field_value(form_state, "text")),
    ]),
    html.button([], [html.text("追加")]),
    ..list.map(errors, fn(error_message) {
      html.p([], [html.text(error_message)])
    })
  ])
}

fn view_todo(todoitem: TodoItem, index: Int) -> Element(Message) {
  html.div([], [
    case todoitem.done {
      True -> html.span([], [html.text("done")])
      False -> html.span([], [html.text("todo?")])
    },
    html.label([], [
      html.input([
        attribute.type_("checkbox"),
        attribute.checked(todoitem.done),
        event.on_check(fn(_) { UserToggledTodo(index) }),
      ]),
      html.text(todoitem.text),
    ]),
  ])
}
