fun renderHTML title body =
  "<!DOCTYPE html>" ^
  "<html>" ^
  "<head>" ^
  "  <title>" ^ title ^ "</title>" ^
  "  <link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/water.css@2/out/water.css\">" ^
  "  <script src=\"https://unpkg.com/htmx.org@1.9.12\" integrity=\"sha384-ujb1lZYygJmzgSwoxRggbCHcjc0rB2XoQrxeTUQyRjrOnlCoYta87iKBWq3EsdM2\" crossorigin=\"anonymous\"></script>" ^
  "  <style>" ^
  "    .htmx-indicator { " ^
  "      opacity: 0;" ^
  "      transition: opacity 500ms ease-in;" ^
  "    }" ^
  "    .htmx-request.htmx-indicator {" ^
  "      opacity: 1;" ^
  "    }" ^
  "    .htmx-request .htmx-indicator {" ^
  "      opacity: 1;" ^
  "    }" ^
  "    ul.no-bullets {" ^
  "      list-style-type: none;" ^
  "      padding: 0;" ^
  "    }" ^
  "    .contact.htmx-swapping {" ^
  "      opacity: 0;" ^
  "      transition: opacity 500ms ease-in;" ^
  "    }" ^
  "  </style>" ^
  "</head>" ^
  "<body>" ^ body ^ "</body>" ^
  "</html>"

fun indicatorSVG id =
  "<svg class=\"htmx-indicator\" id=\"" ^ id ^ "\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" xmlns=\"http://www.w3.org/2000/svg\">" ^
  "  <ellipse cx=\"12\" cy=\"5\" rx=\"4\" ry=\"4\">" ^
  "    <animate id=\"bouncy_goober\" begin=\"0;bouncy_last.end\" attributeName=\"cy\" calcMode=\"spline\" dur=\"0.375s\" values=\"5;20\" keySplines=\".33,0,.66,.33\" fill=\"freeze\"/>" ^
  "    <animate id=\"dont_care\" begin=\"bouncy_goober.end\" attributeName=\"rx\" calcMode=\"spline\" dur=\"0.05s\" values=\"4;4.8;4\" keySplines=\".33,0,.66,.33;.33,.66,.66,1\"/>" ^
  "    <animate id=\"omg_who_cares\" begin=\"bouncy_goober.end\" attributeName=\"ry\" calcMode=\"spline\" dur=\"0.05s\" values=\"4;3;4\" keySplines=\".33,0,.66,.33;.33,.66,.66,1\"/>" ^
  "    <animate id=\"bouncy_middle\" begin=\"bouncy_goober.end\" attributeName=\"cy\" calcMode=\"spline\" dur=\"0.025s\" values=\"20;20.5\" keySplines=\".33,0,.66,.33\"/>" ^
  "    <animate id=\"bouncy_last\" begin=\"bouncy_middle.end\" attributeName=\"cy\" calcMode=\"spline\" dur=\"0.4s\" values=\"20.5;5\" keySplines=\".33,.66,.66,1\"/>" ^
  "  </ellipse>" ^
  "</svg>"
