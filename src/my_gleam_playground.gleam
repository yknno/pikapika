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
  UserSubmitForm(result: Result(TodoInput, Form(TodoInput)))
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
        todos: [TodoItem(text:, done: False), ..model.todos],
        form: new_form(),
      )
    }
    UserSubmitForm(Error(form)) -> {
      Model(..model, form:)
    }
  }
}

fn view(model: Model) -> Element(Message) {
  html.div([attribute.class("max-w-md mx-auto p-6 space-y-4")], [
    view_todo_form(model.form),
    html.ul(
      [attribute.class("rounded border border-gray-200 divide-y divide-gray-200")],
      list.index_map(model.todos, view_todo),
    ),
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

  let error_elements =
    list.map(errors, fn(error_message) {
      html.p([attribute.class("text-sm text-red-600")], [
        html.text(error_message),
      ])
    })

  html.form(
    [
      event.on_submit(handle_submit),
      attribute.class("flex flex-col gap-2"),
    ],
    list.flatten([
      [
        html.label(
          [
            attribute.for("text"),
            attribute.class("text-sm font-medium text-gray-700"),
          ],
          [html.text("やること")],
        ),
        html.input([
          attribute.id("text"),
          attribute.name("text"),
          attribute.value(form.field_value(form_state, "text")),
          attribute.class(
            "rounded border border-gray-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500",
          ),
        ]),
      ],
      error_elements,
      [
        html.button(
          [
            attribute.class(
              "self-start rounded bg-blue-600 px-4 py-2 text-white hover:bg-blue-700",
            ),
          ],
          [html.text("追加")],
        ),
      ],
    ]),
  )
}

fn view_todo(todoitem: TodoItem, index: Int) -> Element(Message) {
  let text_class = case todoitem.done {
    True -> "text-gray-400 line-through"
    False -> "text-gray-800"
  }

  html.li([attribute.class("px-3 py-2")], [
    html.label(
      [attribute.class("flex items-center gap-2 cursor-pointer")],
      [
        html.input([
          attribute.type_("checkbox"),
          attribute.checked(todoitem.done),
          attribute.class("h-4 w-4 accent-blue-600"),
          event.on_check(fn(_) { UserToggledTodo(index) }),
        ]),
        html.span([attribute.class(text_class)], [html.text(todoitem.text)]),
      ],
    ),
  ])
}
