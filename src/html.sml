fun renderHTML title body =
  "<!DOCTYPE html>" ^
  "<html>" ^
  "<head>" ^
  "  <title>" ^ title ^ "</title>" ^
  "  <link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/water.css@2/out/water.css\">" ^
  "  <script src=\"https://unpkg.com/htmx.org@1.9.12\" integrity=\"sha384-ujb1lZYygJmzgSwoxRggbCHcjc0rB2XoQrxeTUQyRjrOnlCoYta87iKBWq3EsdM2\" crossorigin=\"anonymous\"></script>" ^
  "</head>" ^
  "<body>" ^ body ^ "</body>" ^
  "</html>"
