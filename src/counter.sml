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
  "<!DOCTYPE html>" ^
  "<html>" ^
  "<head>" ^
  "<title>Counter</title>" ^
  "<script src=\"https://unpkg.com/htmx.org@1.9.12\" integrity=\"sha384-ujb1lZYygJmzgSwoxRggbCHcjc0rB2XoQrxeTUQyRjrOnlCoYta87iKBWq3EsdM2\" crossorigin=\"anonymous\"></script>" ^
  "</head>" ^
  "<body>" ^
  "<div id=\"counter\">" ^ viewCounter counter ^ "</div>" ^
  "<button hx-post=\"/counter\" hx-target=\"#counter\">Increment</button>" ^
  "</body>" ^
  "</html>"

fun htmlResponse s = response 200 "text/html" s

fun routeCounter (req : request): response =
  case (#method req, #path req) of
    ("GET", "/counter") => htmlResponse (viewPage (!theCounter))
  | ("POST", "/counter") => (
      incrementCounter 1;
      htmlResponse (viewCounter (!theCounter))
    )
  | _ => response 404 "text/plain" "Not found\n"

