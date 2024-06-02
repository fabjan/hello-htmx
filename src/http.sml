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

datatype 'a result = OK of 'a | Error of string

type request = {
  method: string,
  path: string,
  version: string,
  query: (string * string) list
}

type response = {
  status: int,
  headers: (string * string) list,
  body: string
}

fun eq a b = a = b

fun extractPath what =
  case String.tokens (eq #"?") what of
    path :: _ => path
  | _ => what

fun extractQuery what =
  case String.tokens (eq #"?") what of
    _ :: query :: _ => query
  | _ => ""

fun parsePair pair =
  case String.tokens (eq #"=") pair of
    key :: value :: _ => (key, value)
  | _ => (pair, "")

fun parseQuery query =
  case String.tokens (eq #"&") query of
    [] => []
  | pairs => map parsePair pairs

fun decode firstLine =
  case String.tokens (eq #" ") firstLine of
    method :: what :: version :: _ =>
      let
        val path = extractPath what
        val query = parseQuery (extractQuery what)
      in
        OK {method = method, path = path, version = version, query = query}
      end
  | _ => Error "Invalid request"

fun statusString code =
  case code of
    200 => "200 OK"
  | 400 => "400 Bad Request"
  | 404 => "404 Not Found"
  | _ => "500"

fun response status contentType body =
  {
    status = status,
    headers = [
      ("Server", "SML HTTP Server Hack"),
      ("Content-Type", contentType),
      ("Content-Length", Int.toString (String.size body))
    ],
    body = body
  }

fun encode {status, headers, body} =
  let
    fun encodeHeader (k, v) = k ^ ": " ^ v ^ "\r\n"
  in
    "HTTP/1.1 " ^ (statusString status) ^ "\r\n" ^
    String.concat (map encodeHeader headers) ^ "\r\n" ^
    body
  end

fun firstLine str =
  let
    fun isntLineBreak c = c <> #"\r" andalso c <> #"\n"
  in
    Substring.string (Substring.takel isntLineBreak (Substring.full str))
  end

fun handleHTTP sock handler =
  let
    val bytes = Socket.recvVec (sock, 1024)
    val str = Byte.bytesToString bytes
    val reqLine = firstLine str
  in
    print (reqLine ^ "\n");
    let
      val resp =
        case decode reqLine of
          OK req => handler req
        | Error msg => (
          print ("Invalid request: " ^ msg ^ "\n");
          response 400 "text/plain" "Bad request, dude"
        )
      val encoded = encode resp
      val bytes = Byte.stringToBytes encoded
      val size = Word8Vector.length bytes
    in
      print (statusString (#status resp) ^ " (" ^ (Int.toString size) ^ " bytes)\n");
      Socket.sendVec (sock, Word8VectorSlice.full bytes)
    end
  end

fun serveHTTP serverSock handler =
  let
    val _ = print "Waiting for connection...\n"
    val (clientSock, _) = Socket.accept serverSock
  in
    print "Accepted connection, handling request.\n";
    handleHTTP clientSock handler;
    (* TODO: Persistent connections *)
    Socket.close clientSock;
    serveHTTP serverSock handler
  end

fun listenTCP port =
  let
    val sock: Socket.passive INetSock.stream_sock = INetSock.TCP.socket ()
  in
    Socket.Ctl.setREUSEADDR (sock, true);
    Socket.bind (sock, INetSock.any port);
    Socket.listen (sock, 5);
    sock
  end
