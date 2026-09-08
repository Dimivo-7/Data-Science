-- Markiert Glossarbegriffe im Fliesstext und baut die Glossarseite.
--
-- Die Begriffe stehen in glossary.yml, das ueber metadata-files in
-- _quarto.yml eingebunden ist und deshalb hier als meta.glossary ankommt.
-- Laeuft zur Build-Zeit, braucht keine externen Abhaengigkeiten.
--
-- Zwei Aufgaben:
--   1. Jeden Begriff einmal je Seite in ein <span class="glossary-term">
--      mit data-def verpacken. Den Tooltip zeichnet styles.scss.
--   2. Auf der Glossarseite den Platzhalter #glossar-liste durch die
--      vollstaendige, nach Themen gruppierte Liste ersetzen.

local stringify = pandoc.utils.stringify

local terms = {}       -- Suchform -> Eintrag
local entries = {}     -- fuer die Glossarseite, in Reihenfolge der yml-Datei
local maxWords = 1     -- laengster Begriff in Woertern
local active = false   -- Glossar auf dieser Seite ueberhaupt anwenden?

-- ---------------------------------------------------------------------------
-- Kleinschreibung inklusive Umlauten
-- ---------------------------------------------------------------------------
-- string.lower arbeitet byteweise und laesst Mehrbyte-Zeichen unberuehrt.
-- "Überanpassung" wuerde sonst nie auf "überanpassung" passen.

local UMLAUTE = {
  ["Ä"] = "ä", ["Ö"] = "ö", ["Ü"] = "ü",
  ["É"] = "é", ["È"] = "è", ["Ê"] = "ê",
  ["À"] = "à", ["Â"] = "â", ["Ç"] = "ç",
}

local function lower(s)
  for gross, klein in pairs(UMLAUTE) do
    s = s:gsub(gross, klein)
  end
  return s:lower()
end

-- ---------------------------------------------------------------------------
-- Satzzeichen vom Wort trennen
-- ---------------------------------------------------------------------------
-- Pandoc haengt Satzzeichen an das Str-Element: aus "Median," wird ein
-- einziger Str. Fuer den Vergleich brauchen wir den nackten Wortkern.

-- Bewusst nur ASCII-Satzzeichen. Lua-Muster arbeiten byteweise; eine
-- Zeichenklasse mit typografischen Anfuehrungszeichen wuerde deren einzelne
-- Bytes enthalten und dann auch aus anderen UTF-8-Zeichen Bytes abschneiden -
-- der Gedankenstrich beginnt mit demselben Byte wie sie. Ergebnis waere
-- zerstoerter Text. Ein Begriff in typografischen Anfuehrungszeichen bekommt
-- dafuer keinen Tooltip; das ist der harmlosere Fehler.
local VORNE  = '^[%(%[%{"\']*'
local HINTEN = '[%.,;:%!%?%)%]%}"\']*$'

local function zerlege(wort)
  local vorne = wort:match(VORNE) or ""
  local hinten = wort:match(HINTEN) or ""
  local kern = wort:sub(#vorne + 1, #wort - #hinten)
  return vorne, kern, hinten
end

-- ---------------------------------------------------------------------------
-- Metadaten einlesen
-- ---------------------------------------------------------------------------

function Meta(meta)
  -- Zustand zuruecksetzen. Falls Quarto denselben Lua-Zustand fuer mehrere
  -- Dokumente wiederverwendet, wuerden sonst Eintraege doppelt in der Liste
  -- landen und "schon markiert" von der Vorseite nachwirken.
  terms, entries, maxWords, active = {}, {}, 1, false

  if not quarto.doc.is_format("html:js") then
    return meta
  end

  if not meta.glossary then
    return meta
  end

  for _, roh in ipairs(meta.glossary) do
    local begriff = stringify(roh.term or "")
    local definition = stringify(roh.def or "")

    if begriff ~= "" and definition ~= "" then
      local eintrag = {
        term  = begriff,
        def   = definition,
        topic = roh.topic and stringify(roh.topic) or "Allgemein",
      }
      entries[#entries + 1] = eintrag

      -- Der Begriff selbst und alle Aliasse zeigen auf denselben Eintrag
      local schreibweisen = { begriff }
      if roh.aliases then
        for _, a in ipairs(roh.aliases) do
          schreibweisen[#schreibweisen + 1] = stringify(a)
        end
      end

      for _, form in ipairs(schreibweisen) do
        terms[lower(form)] = eintrag
        local n = select(2, form:gsub("%S+", "")) -- Woerter zaehlen
        if n > maxWords then maxWords = n end
      end
    end
  end

  -- glossary-skip schaltet nur das Markieren im Text ab, nicht das Einlesen:
  -- die Glossarseite selbst traegt dieses Flag und braucht die Eintraege
  -- trotzdem, um die Liste zu bauen.
  active = (next(terms) ~= nil) and not meta["glossary-skip"]
  return meta
end

-- ---------------------------------------------------------------------------
-- Treffer suchen
-- ---------------------------------------------------------------------------
-- Ein Begriff aus n Woertern belegt die Positionen i, i+2, i+4 ... weil
-- zwischen zwei Str-Elementen immer ein Space steht. Geprueft wird vom
-- laengsten zum kuerzesten Begriff, damit "Zentraler Grenzwertsatz" gewinnt
-- und nicht schon "Grenzwertsatz" zuschlaegt.

local function passt(inlines, i, n)
  local woerter, vorne, hinten = {}, "", ""

  for w = 1, n do
    local pos = i + (w - 1) * 2
    local el = inlines[pos]
    if not el or el.t ~= "Str" then return nil end
    if w > 1 then
      local trenner = inlines[pos - 1]
      if not trenner or trenner.t ~= "Space" then return nil end
    end

    local v, kern, h = zerlege(el.text)
    if kern == "" then return nil end
    -- Satzzeichen duerfen nur aussen stehen, nicht mitten im Begriff
    if w == 1 then vorne = v elseif v ~= "" then return nil end
    if w == n then hinten = h elseif h ~= "" then return nil end

    woerter[w] = kern
  end

  local text = table.concat(woerter, " ")
  local eintrag = terms[lower(text)]
  if not eintrag then return nil end

  return { eintrag = eintrag, woerter = woerter, vorne = vorne, hinten = hinten }
end

local function baueSpan(treffer)
  local inhalt = {}
  for w, wort in ipairs(treffer.woerter) do
    if w > 1 then inhalt[#inhalt + 1] = pandoc.Space() end
    inhalt[#inhalt + 1] = pandoc.Str(wort)
  end

  return pandoc.Span(inhalt, pandoc.Attr("", { "glossary-term" }, {
    ["data-def"]   = treffer.eintrag.def,
    ["data-topic"] = treffer.eintrag.topic,
    ["tabindex"]   = "0",
  }))
end

-- Inline-Elemente, in deren Inhalt weitergesucht wird. Ohne das bliebe ein
-- fett gesetzter Begriff unmarkiert - und in dieser Sammlung stehen etliche
-- Fachbegriffe genau so im Text.
local REKURSION = {
  Emph = true, Strong = true, Underline = true, Strikeout = true,
  SmallCaps = true, Superscript = true, Subscript = true,
  Span = true, Quoted = true,
}

-- Bewusst NICHT rekursiv: Link, Code, Math, Note, Image, RawInline. Sie
-- werden unveraendert durchgereicht, ihr Inhalt bleibt damit unberuehrt.

local function markiere(inlines)
  local raus = pandoc.Inlines({})
  local i = 1

  while i <= #inlines do
    local treffer = nil
    local laenge = 0

    -- Jedes Vorkommen wird markiert, nicht nur das erste je Seite. Wer auf
    -- Seite drei ueber einen Begriff stolpert, soll die Erklaerung dort
    -- bekommen und nicht erst weiter oben suchen muessen.
    for n = math.min(maxWords, #inlines), 1, -1 do
      local t = passt(inlines, i, n)
      if t then
        treffer, laenge = t, n
        break
      end
    end

    if treffer then
      if treffer.vorne ~= "" then raus:insert(pandoc.Str(treffer.vorne)) end
      raus:insert(baueSpan(treffer))
      if treffer.hinten ~= "" then raus:insert(pandoc.Str(treffer.hinten)) end
      i = i + (laenge - 1) * 2 + 1
    else
      local el = inlines[i]
      if REKURSION[el.t] and el.content then
        el.content = markiere(el.content)
      end
      raus:insert(el)
      i = i + 1
    end
  end

  return raus
end

-- ---------------------------------------------------------------------------
-- Glossarseite
-- ---------------------------------------------------------------------------

local function escape(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"))
end

local function glossarListe()
  -- nach Thema gruppieren, Themen und Begriffe jeweils alphabetisch
  local themen, namen = {}, {}
  for _, e in ipairs(entries) do
    if not themen[e.topic] then
      themen[e.topic] = {}
      namen[#namen + 1] = e.topic
    end
    table.insert(themen[e.topic], e)
  end
  table.sort(namen)

  local html = {}
  for _, thema in ipairs(namen) do
    local liste = themen[thema]
    table.sort(liste, function(a, b) return lower(a.term) < lower(b.term) end)

    html[#html + 1] = '<section class="glossary-group">'
    html[#html + 1] = '<h2 class="glossary-group__title">' .. escape(thema) .. "</h2>"

    for _, e in ipairs(liste) do
      html[#html + 1] = table.concat({
        '<article class="glossary-entry" data-term="', escape(e.term), '">',
        '<h3 class="glossary-entry__term">', escape(e.term), "</h3>",
        '<p class="glossary-entry__def">', escape(e.def), "</p>",
        '<div class="glossary-entry__pages" data-term="', escape(e.term), '">',
        '<span class="glossary-entry__pending">Seiten werden gesucht …</span>',
        "</div>",
        "</article>",
      })
    end

    html[#html + 1] = "</section>"
  end

  if #html == 0 then
    return pandoc.RawBlock("html", '<p class="glossary-empty">Das Glossar ist noch leer.</p>')
  end

  return pandoc.RawBlock("html", table.concat(html, "\n"))
end

-- ---------------------------------------------------------------------------
-- Filter
-- ---------------------------------------------------------------------------
-- topdown, damit das zweite Rueckgabeargument false die Kinder aussparen kann.
-- Ohne das wuerde der Filter auch in Ueberschriften, Links und Code markieren.

return {
  { Meta = Meta },
  {
    traverse = "topdown",

    -- Diese Bloecke bleiben komplett aussen vor. Das zweite Rueckgabe-
    -- argument false stoppt den Abstieg, sodass auch ihr Innenleben
    -- unberuehrt bleibt - bei Table etwa die Zellen, bei Figure die
    -- Bildunterschrift.
    Header = function(el) return el, false end,
    Table  = function(el) return el, false end,
    Figure = function(el) return el, false end,

    -- Quarto baut Abbildungen und Tabellen als Div auf. Der einzige Text
    -- darin ist die Bildunterschrift, und ein Tooltip dort sprengt den
    -- Ausgabecontainer: der traegt overflow: auto, der absolut positionierte
    -- Kasten vergroessert dessen scrollWidth und die Abbildung bekommt
    -- Scrollleisten. Der Figure-Ausschluss oben greift hier nicht, weil die
    -- Abbildung zu diesem Zeitpunkt noch kein pandoc-Figure ist.
    Div = function(el)
      if el.identifier == "glossar-liste" then
        return pandoc.Div(glossarListe(), el.attr), false
      end
      for _, klasse in ipairs(el.classes) do
        if klasse == "quarto-float"
          or klasse == "cell-output-display"
          or klasse == "quarto-figure" then
          return el, false
        end
      end
      return el
    end,

    -- Bewusst Para und Plain statt eines generischen Inlines-Filters.
    -- Mit Inlines wurden Aufzaehlungen nicht erreicht - und dort steht in
    -- diesem Projekt unter "Kernideen" jeder Begriff zum ersten Mal.
    -- Plain deckt die Listenpunkte ab, Para den Fliesstext; markiere()
    -- steigt selbst in Emph, Strong und Span ab und laesst Links und Code
    -- in Ruhe. Deshalb hier false: der Abstieg ist bereits erledigt.
    Para = function(el)
      if not active then return nil end
      el.content = markiere(el.content)
      return el, false
    end,

    Plain = function(el)
      if not active then return nil end
      el.content = markiere(el.content)
      return el, false
    end,
  },
}
