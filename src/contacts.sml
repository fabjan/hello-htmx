(* TODO: extra numeric ID? *)
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
  "<li id=\"contact-" ^ name ^ "\">" ^
    "<span hx-indicator=\"#ci-" ^ name ^ "\" hx-target=\"#contact-" ^ name ^ "\" hx-swap=\"outerHTML\" hx-delete=\"/contacts/" ^ name ^ "\" style=\"cursor: pointer\">&#x1F9F9;</span>" ^
    name ^ ", " ^ email ^
    indicatorSVG ("ci-" ^ name) ^
  "</li>"

fun viewContacts contacts =
  "<ul class=\"no-bullets\" id=\"contacts\">" ^ String.concat (List.map viewContact contacts) ^ "</ul>"

fun oobContact contact =
  "<ul id=\"contacts\" hx-swap-oob=\"afterbegin\">" ^ viewContact contact ^ "</ul>"

fun indexContacts formData contacts =
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
    "<p id=\"insert\">" ^ editContact formData [] ^ "</p>" ^
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
(* FIXME: empty name should not be allowed *)
(* FIXME: duplicate name should not be allowed, maybe? *)
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

fun deleteContact name =
  let
    val contacts = !theContacts
    val contacts' = List.filter (fn c => not (eq (#name c) name)) contacts
    (* hack to simulate slow response, showcasing interactivity *)
    val _ = OS.Process.sleep (Time.fromMilliseconds 1337)
  in
    if List.length contacts = List.length contacts'
    then response 404 "text/plain" "Not found\n"
    else (
      theContacts := contacts';
      response 200 "text/html" "<!-- deleted -->"
    )
  end

fun routeContacts (req : request): response =
  case (#method req, (String.tokens (eq #"/") (#path req)), #query req) of
    ("GET", ["contacts"], []) => response 200 "text/html" (indexContacts (newContact "" "") (!theContacts))
  | ("GET", ["contacts"], params) => updateContacts params
  | ("DELETE", ["contacts", name], _) => deleteContact name
  | _ => response 404 "text/plain" "Not found\n"

