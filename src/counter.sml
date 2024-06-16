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

fun htmlResponse s = response Http.StatusCode.OK "text/html" s

fun routeCounter method path _ : Smelly.response =
  case (method, path) of
    (Http.Request.GET, ["counter"]) => htmlResponse (viewPage (!theCounter))
  | (Http.Request.POST, ["counter"]) => (
      incrementCounter 1;
      htmlResponse (viewCounter (!theCounter))
    )
  | _ => response Http.StatusCode.NotFound "text/plain" "Not found\n"

