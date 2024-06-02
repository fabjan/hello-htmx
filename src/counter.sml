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

fun htmlResponse s = response 200 "text/html" s

fun routeCounter (req : request): response =
  case (#method req, #path req) of
    ("GET", "/counter") => htmlResponse (viewPage (!theCounter))
  | ("POST", "/counter") => (
      incrementCounter 1;
      htmlResponse (viewCounter (!theCounter))
    )
  | _ => response 404 "text/plain" "Not found\n"

