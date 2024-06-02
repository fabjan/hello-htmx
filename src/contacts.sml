type contact = { name : string, email : string }

fun newContact name email = { name = name, email = email }

(* TODO: handler state can be immutable if we pass it around *)
val theContacts = ref [
  { name = "Alice", email = "alice@example.com" },
  { name = "Bob", email = "bob@example.com" }
]

fun containsEmail needle (haystack : contact list) =
  List.exists (eq needle) (List.map #email haystack)

fun addContact contact =
  let
    val contacts = !theContacts
    val contacts' = contact :: contacts
  in
    theContacts := contacts'
  end

fun viewError e = "<span style=\"color: red\">" ^ e ^ "</span>"

fun editContact { name, email } (errors : string list) =
  (* TODO: form body parsing, to support POST *)
  "<form hx-get=\"/contacts\" hx-swap=\"outerHTML\">" ^
  "  <input type=\"text\" name=\"name\" value=\"" ^ name ^ "\">" ^
  "  <input type=\"text\" name=\"email\" value=\"" ^ email ^ "\">" ^
  String.concat (List.map viewError errors) ^
  "  <button type=\"submit\">Save Contact</button>" ^
  "</form>"

(* FIXME: sanitize *)
fun viewContact { name, email } =
  "<li>" ^ name ^ ", " ^ email ^ "</li>"

fun viewContacts contacts =
  "<ul id=\"contacts\">" ^ String.concat (List.map viewContact contacts) ^ "</ul>"

fun oobContact contact =
  "<ul id=\"contacts\" hx-swap-oob=\"afterbegin\">" ^ viewContact contact ^ "</ul>"

fun indexContacts contacts =
  renderHTML "Contacts" (
    "<script>" ^
    "document.addEventListener('DOMContentLoaded', function() {" ^
    "  document.body.addEventListener('htmx:beforeSwap', function(event) {" ^
    (* 409 is expected in this app *)
    "    if (event.detail.xhr.status == 409) {" ^
    "      event.detail.shouldSwap = true;" ^
    "      event.detail.isError = false;" ^
    "    }" ^
    "  });" ^
    "});" ^
    "</script>" ^
    "<p id=\"insert\">" ^ editContact (newContact "" "") [] ^ "</p>" ^
    viewContacts contacts
  )

fun parseEmail s =
  let
    (* FIXME: this is not right *)
    fun parse (#"%" :: #"4" :: #"0" :: rest) = #"@" :: rest
      | parse (c :: rest) = c :: parse rest
      | parse [] = []
  in
    String.implode (parse (String.explode s))
  end

local
fun updateContacts' name email =
  let
    val email = parseEmail email
    val contact = newContact name email
  in
    if containsEmail email (!theContacts)
    then response 409 "text/html" (editContact contact ["Email already exists"])
    else (
      addContact contact;
      (* return the form, but also update out of band *)
      response 200 "text/html" ((editContact contact []) ^ (oobContact contact))
    )
  end
in
fun updateContacts [("name", name), ("email", email)] = updateContacts' name email
  | updateContacts [("email", email), ("name", name)] = updateContacts' name email
  | updateContacts _ = response 400 "text/plain" "Bad request\n"
end

fun routeContacts (req : request): response =
  case (#method req, #path req, #query req) of
    ("GET", "/contacts", []) => response 200 "text/html" (indexContacts (!theContacts))
  | ("GET", "/contacts", params) => updateContacts params
  | _ => response 404 "text/plain" "Not found\n"

