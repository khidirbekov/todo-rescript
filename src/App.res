module Todo = {
  type t = {id: float, name: string, status: bool}

  let toggle = todo => {...todo, status: !todo.status}

  let getName = todo => todo.name
  let getStatus = todo => {
    switch todo.status {
    | true => "done"
    | false => "active"
    }
  }
}

module TodoItem = {
  @react.component
  let make = (~onToggle, ~todo, ~onRemove) =>
    <li>
      {todo->Todo.getName->React.string}
      <button onClick={_ => onToggle()}> {React.string(Todo.getStatus(todo))} </button>
      <button onClick={_ => onRemove()}> {"Remove"->React.string} </button>
    </li>
}

module App = {
  type state = {todos: array<Todo.t>, input: string}

  let defaultState = {todos: [], input: ""}

  type action = Add | Remove({id: int}) | Toggle({id: int}) | InputChange({value: string})

  let reducer = (state, action) =>
    switch action {
    | Add => {
        input: "",
        todos: state.todos->Js.Array2.concat([
          {id: Js.Date.now(), name: state.input, status: false},
        ]),
      }
    | Remove({id}) => {...state, todos: state.todos->Js.Array2.filteri((_, i) => i != id)}
    | Toggle({id}) => {
        ...state,
        todos: state.todos->Js.Array2.mapi((todo, i) =>
          if id == i {
            todo->Todo.toggle
          } else {
            todo
          }
        ),
      }
    | InputChange({value}) => {...state, input: value}
    }

  @react.component
  let make = () => {
    let ({todos, input}, dispatch) = React.useReducer(reducer, defaultState)

    <>
      <input
        value={input}
        onChange={event => {
          let value = ReactEvent.Form.target(event)["value"]
          dispatch(InputChange({value: value}))
        }}
      />
      <button onClick={_ => dispatch(Add)}> {React.string("Create")} </button>
      <ol>
        {todos
        ->Js.Array2.mapi((todo, i) =>
          <TodoItem
            key={i->Js.Int.toString}
            todo={todo}
            onToggle={() => dispatch(Toggle({id: i}))}
            onRemove={() => dispatch(Remove({id: i}))}
          />
        )
        ->React.array}
      </ol>
    </>
  }
}
