type block = { id : int }

fun makeBlocks start = List.tabulate (10, fn i => { id = start + i })

fun viewBlock (block: block) =
  "<blockquote>" ^
  "  <p>Hello this is block " ^ Int.toString (#id block) ^ "</p>" ^
  "</blockquote>"

fun viewMore false next =
    "<button hx-swap=\"outerHTML\" hx-get=\"/blocks?start=" ^ (Int.toString next) ^ "\" hx-indicator=\"dots\">Show me more!</button>"
  | viewMore true next =
    "<div hx-trigger=\"revealed\" hx-swap=\"outerHTML\" hx-get=\"/blocks?start=" ^ (Int.toString next) ^ "\" hx-indicator=\"dots\"></div>"

fun viewBlocks start =
  let
    val blocks = List.map viewBlock (makeBlocks start)
    val next = start + 10
    val more = next < 100
  in
    (String.concat blocks) ^ (viewMore more next)
  end

fun getBlocksFrom NONE = response Http.Status.BadRequest "text/plain" "Bad request\n"
  | getBlocksFrom (SOME start) = response Http.Status.Ok "text/html" (viewBlocks start)

fun indexBlocks () =
  renderHTML "Blocks" (
    "<div style=\"display: flex; flex-direction: column\">" ^
    viewBlocks 0 ^
    "</div>"
  )

fun routeBlocks method path (req : Http.Request.t): Http.Response.t =
  case (method, path, #query req) of
    (Http.Method.Get, ["blocks"], []) => response Http.Status.Ok "text/html" (indexBlocks ())
  | (Http.Method.Get, ["blocks"], [("start", start)]) => getBlocksFrom (Int.fromString start)
  | (_, ["blocks"], _) => response Http.Status.BadRequest "text/plain" "Bad request\n"
  | _ => response Http.Status.NotFound "text/plain" "Not found\n"

