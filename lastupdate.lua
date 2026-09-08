-- Fügt oben auf jeder HTML-Seite den Zeitpunkt des letzten Renderings ein.
-- Läuft zur Build-Zeit, braucht keine externen Abhängigkeiten.

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

  local html = table.concat({
    '<div class="last-update">',
    '<span class="last-update__dot" aria-hidden="true"></span>',
    '<span class="last-update__label">Letztes Update</span>',
    '<time class="last-update__time">', stamp, '</time>',
    '</div>'
  })

  table.insert(doc.blocks, 1, pandoc.RawBlock("html", html))
  return doc
end
