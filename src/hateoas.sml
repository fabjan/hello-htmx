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
 * A simple HTMX app.
 *)

fun viewIndex () =
  renderHTML "HATEOAS" (
    "<h2>Hypermedia As The Engine Of Application State</h2>" ^
    "<ul>" ^
    "<li><a href=\"/counter\">Counter</a></li>" ^
    "<li><a href=\"/contacts\">Contacts</a></li>" ^
    "<li><a href=\"/blocks\">Blocks</a></li>" ^
    "</ul>"
  )

fun router (req : Http.Request.t): Http.Response.t =
  let
    val method = #method req
    val path = #path req
    val path = String.tokens (fn c => c = #"/") path
  in
    case (method, path) of
      (_, "counter"::_) => routeCounter method path req
    | (_, "contacts"::_) => routeContacts method path req
    | (_, "blocks"::_) => routeBlocks method path req
    | (Http.Method.Get, []) => response Http.Status.Ok "text/html" (viewIndex ())
    | _ => response Http.Status.NotFound "text/plain" "Not found\n"
  end

fun main () =
  let
    val portOpt = Option.mapPartial Int.fromString (OS.Process.getEnv "PORT")
    val port =
      case portOpt of
        NONE => 3000
      | SOME x => x
    val sock = INetSock.TCP.socket () : Smelly.listen_sock
  in
    Socket.Ctl.setREUSEADDR (sock, true);
    Socket.bind (sock, INetSock.any port);
    Socket.listen (sock, 5);
    print ("Serving at http://localhost:" ^ (Int.toString port) ^ "\n");
    Smelly.serve sock router
  end
