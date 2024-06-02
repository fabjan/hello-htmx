(*
 * Copyright 2023 Fabian Bergström
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *)

(*
 * A simple HTTP service.
 *)

fun viewIndex () =
  renderHTML "HATEOAS" (
    "<h2>Hypermedia As The Engine Of Application State</h2>" ^
    "<ul>" ^
    "<li><a href=\"/counter\">Counter</a></li>" ^
    "<li><a href=\"/contacts\">Contacts</a></li>" ^
    "</ul>"
  )

fun router (req : request): response =
  case (#method req, String.tokens (eq #"/") (#path req)) of
    (_, "counter"::_) => routeCounter req
  | (_, "contacts"::_) => routeContacts req
  | ("GET", []) => response 200 "text/html" (viewIndex ())
  | _ => response 404 "text/plain" "Not found\n"

fun main () =
  let
    val portOpt = Option.mapPartial Int.fromString (OS.Process.getEnv "PORT")
    val port =
      case portOpt of
        NONE => 3000
      | SOME x => x
    val sock = listenTCP port
  in
    print ("Listening on port " ^ (Int.toString port) ^ "\n");
    serveHTTP sock router
  end
