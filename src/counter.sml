datatype counter = Count of int

(* TODO: handler state can be immutable if we pass it around *)
val theCounter = ref (Count 0)

fun incrementCounter incr =
  let
    val Count n = !theCounter
  in
    theCounter := Count (n + incr)
  end

fun viewCounter (Count i) = "Count: " ^ Int.toString i

fun viewPage counter =
  renderHTML "Counter" (
    "<p id=\"counter\">" ^ viewCounter counter ^ "</p>" ^
    "<button hx-post=\"/counter\" hx-target=\"#counter\">Increment</button>"
  )

fun htmlResponse s = response Http.Status.Ok "text/html" s

fun routeCounter method path _ : Http.Response.t =
  case (method, path) of
    (Http.Method.Get, ["counter"]) => htmlResponse (viewPage (!theCounter))
  | (Http.Method.Post, ["counter"]) => (
      incrementCounter 1;
      htmlResponse (viewCounter (!theCounter))
    )
  | _ => response Http.Status.NotFound "text/plain" "Not found\n"

