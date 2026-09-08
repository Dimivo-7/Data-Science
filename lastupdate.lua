-- Zeigt den Zeitpunkt des letzten Renderings in der Navigationsleiste.
-- Laeuft zur Build-Zeit, braucht keine externen Abhaengigkeiten.
--
-- Der Stempel steht bewusst in der Navbar und nicht im Seiteninhalt: er gilt
-- fuer die ganze Website, nicht fuer eine einzelne Seite.
--
-- ABSCHALTEN: die Zeile "- lastupdate.lua" unter format.html.filters in
-- _quarto.yml entfernen. Das ist alles - keine einzige .qmd-Datei ist
-- betroffen, weil der Stempel nirgends im Quelltext der Seiten steht.
--
-- Warum ein Skript: die Navbar erzeugt Quartos Template, sie ist im
-- Dokumentbaum, den ein Lua-Filter sieht, nicht enthalten. Der Zeitstempel
-- selbst entsteht weiterhin hier, zur Build-Zeit; das Skript haengt ihn nur
-- an die richtige Stelle.

local MONTHS = {
  "Januar", "Februar", "März", "April", "Mai", "Juni",
  "Juli", "August", "September", "Oktober", "November", "Dezember"
}

function Pandoc(doc)
  if not quarto.doc.is_format("html:js") then
    return doc
  end

  local now = os.date("*t")
  local stamp = string.format(
    "%d. %s %d, %02d:%02d",
    now.day, MONTHS[now.month], now.year, now.hour, now.min
  )

  local html = '<span class="last-update__dot" aria-hidden="true"></span>'
    .. '<span class="last-update__label">Letztes Update</span>'
    .. '<time class="last-update__time">' .. stamp .. "</time>"

  -- %q liefert einen korrekt maskierten String; das Format ist hier auch
  -- fuer JavaScript gueltig, weil html keine Zeilenumbrueche enthaelt.
  local script = table.concat({
    "<script>",
    "(function () {",
    '  var nav = document.querySelector(".navbar .navbar-container")',
    '         || document.querySelector(".navbar");',
    "  if (!nav) { return; }",
    '  var box = document.createElement("div");',
    '  box.className = "last-update";',
    "  box.innerHTML = " .. string.format("%q", html) .. ";",
    '  var tools = nav.querySelector(".quarto-navbar-tools");',
    "  if (tools) { nav.insertBefore(box, tools); } else { nav.appendChild(box); }",
    "})();",
    "</script>",
  }, "\n")

  quarto.doc.include_text("after-body", script)
  return doc
end
