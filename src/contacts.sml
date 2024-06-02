type contact = { name : string, email : string }

fun newContact name email = { name = name, email = email }

(* TODO: handler state can be immutable if we pass it around *)
val theContacts = ref [
  { name = "Alice", email = "alice@example.com" },
  { name = "Bob", email = "bob@example.com" }
]

fun addContact contact =
  let
    val contacts = !theContacts
    val contacts' = contact :: contacts
  in
    theContacts := contacts'
  end

fun editContact { name, email } =
  (* TODO: form body parsing, to support POST *)
  "<form hx-get=\"/contacts\" hx-target=\"#contacts\" hx-swap=\"outerHTML\">" ^
  "  <input type=\"text\" name=\"name\" value=\"" ^ name ^ "\">" ^
  "  <input type=\"text\" name=\"email\" value=\"" ^ email ^ "\">" ^
  "  <button type=\"submit\">Save Contact</button>" ^
  "</form>"


(* FIXME: sanitize *)
fun viewContact { name, email } =
  "<li>" ^ name ^ ", " ^ email ^ "</li>"

fun viewContacts contacts =
  "<ul id=\"contacts\">" ^ String.concat (List.map viewContact contacts) ^ "</ul>"

fun viewPage contacts =
  renderHTML "Contacts" (
    "<p id=\"insert\">" ^ editContact (newContact "" "") ^ "</p>" ^
    viewContacts contacts
  )

fun htmlResponse s = response 200 "text/html" s

fun parseEmail s =
  let
    (* FIXME: this is not right *)
    fun parse (#"%" :: #"4" :: #"0" :: rest) = #"@" :: rest
      | parse (c :: rest) = c :: parse rest
      | parse [] = []
  in
    String.implode (parse (String.explode s))
  end

fun handleContacts (req : request) =
  case #query req of
    [] => htmlResponse (viewPage (!theContacts))
  | [("name", name), ("email", email)] =>
      let
        val email = parseEmail email
      in
        addContact (newContact name email);
        htmlResponse (viewContacts (!theContacts))
      end
  | _ => response 400 "text/plain" "Bad request\n"

fun routeContacts (req : request): response =
  case (#method req, #path req) of
    ("GET", "/contacts") => handleContacts req
  | _ => response 404 "text/plain" "Not found\n"

