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
  Login(Form(LoginData))
  LoggedIn(username: String)
}

type LoginData {
  LoginData(username: String, password: String)
}

fn init(_) -> Model {
  Login(new_login_form())
}

fn new_login_form() -> Form(LoginData) {
  form.new({
    use username <- form.field(
      "username",
      form.parse_string |> form.check_not_empty,
    )

    let check_password = fn(password) {
      case password == "xxxxxxx" {
        True -> Ok(password)
        False -> Error("Password not valid")
      }
    }

    use password <- form.field(
      "password",
      form.parse_string |> form.check(check_password),
    )

    form.success(LoginData(username:, password:))
  })
}

type Message {
  UserSubmittedForm(Result(LoginData, Form(LoginData)))
}

fn update(_model: Model, message: Message) -> Model {
  case message {
    UserSubmittedForm(Ok(LoginData(username:, ..))) -> {
      LoggedIn(username:)
    }
    UserSubmittedForm(Error(form)) -> {
      Login(form)
    }
  }
}

fn view(model: Model) -> Element(Message) {
  html.div(
    [attribute.class("p-32 mx-auto w-full max-w-2xl space-y-4")],
    case model {
      Login(form) -> [view_login(form)]
      LoggedIn(username:) -> [view_loggedin(username)]
    },
  )
}

fn view_loggedin(username: String) {
  element.fragment([
    html.h1([attribute.class("text-2xl font-medium")], [
      html.text("Welcome, "),
      html.span([attribute.class("text-purple-600 font-bold")], [
        html.text(username),
      ]),
      html.text("!"),
    ]),
    html.p([], [html.text("I hope you're having a lovely day!")]),
  ])
}

fn view_login(form: Form(LoginData)) -> Element(Message) {
  let handle_submit = fn(values) {
    form |> form.add_values(values) |> form.run |> UserSubmittedForm
  }

  html.form(
    [
      attribute.class("p-8 w-full border rounded-2xl shadow-lg space-y-4"),
      event.on_submit(handle_submit),
    ],
    [
      html.h1([attribute.class("text-2xl font-medium text-purple-600")], [
        html.text("Sign in"),
      ]),
      view_input(form, is: "text", name: "username", label: "Username"),
      view_input(form, is: "password", name: "password", label: "Password"),
      html.div([attribute.class("flex justify-end")], [
        html.button(
          [
            attribute.class("text-white text-sm font-bold"),
            attribute.class("px-4 py-2 bg-purple-600 rounded-lg"),
            attribute.class("hover:bg-purple-800"),
            attribute.class(
              "focus:outline-2 focus:outline-offset-2 focus:outline-purple-800",
            ),
          ],
          [html.text("Login")],
        ),
      ]),
    ],
  )
}

fn view_input(
  form: Form(LoginData),
  is type_: String,
  name name: String,
  label label: String,
) -> Element(message) {
  let errors = form.field_error_messages(form, name)

  html.div([], [
    html.label(
      [attribute.for(name), attribute.class("text-xs font-bold text-slate-600")],
      [html.text(label), html.text(": ")],
    ),
    html.input([
      attribute.type_(type_),
      attribute.class(
        "block mt-1 w-full px-3 py-1 border rounded-lg focus:shadow",
      ),
      case errors {
        [] -> attribute.class("focus:outline focus:outline-purple-600")
        _ -> attribute.class("outline outline-red-500")
      },
      // we use the `id` in the associated `for` attribute on the label.
      attribute.id(name),
      // the `name` attribute is used as the first element of the tuple
      // we receive for this input.
      attribute.name(name),
    ]),
    // formal provides us with customisable error messages for every element
    // in case its validation fails, which we can show right below the input.
    ..list.map(errors, fn(error_message) {
      html.p([attribute.class("mt-0.5 text-xs text-red-500")], [
        html.text(error_message),
      ])
    })
  ])
}
