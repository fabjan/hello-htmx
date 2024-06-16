structure Http = Smelly.Http

fun response status contentType body : Http.Response.t =
  let
    val length = String.size body
    val headers = [
      ("Content-Type", contentType),
      ("Content-Length", Int.toString length)
    ]
  in
    Http.Response.mk status headers body
  end
