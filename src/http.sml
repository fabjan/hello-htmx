fun response status contentType body =
  let
    val length = String.size body
    val headers = [
      ("Content-Type", contentType),
      ("Content-Length", Int.toString length)
    ]
  in
    Smelly.mkResponse status headers body
  end
