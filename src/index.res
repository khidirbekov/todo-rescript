open App

let _ = switch ReactDOM.querySelector("#root") {
| None => Js.log("Root component not exist")
| Some(element) => ReactDOM.render(<App />, element)
}
