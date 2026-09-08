-- Macht aus einem einfachen Markdown-Block eine anklickbare Quizfrage.
-- Laeuft zur Build-Zeit, braucht keine externen Abhaengigkeiten.
--
-- AUTORENFORMAT
--
--   ::: {.quiz}
--   Der Median liegt bei 15, das Mittel bei 68. Was folgt daraus?
--
--   - [ ] Ein Rechenfehler ~ Beide Masse duerfen weit auseinanderliegen.
--   - [x] Die Verteilung ist rechtsschief ~ Genau, der lange rechte Rand
--         zieht das Mittel nach oben.
--   - [ ] Die Stichprobe ist zu klein ~ Der Umfang sagt ueber die Schiefe
--         nichts aus.
--   :::
--
--   Alles vor der Aufzaehlung ist die Frage und darf normales Markdown
--   enthalten, auch Formeln und Inline-Code. Jede Aufzaehlungszeile ist eine
--   Antwort; [x] markiert die richtige. Nach der Tilde folgt die Erklaerung,
--   die beim Anklicken erscheint. Mehrere richtige Antworten sind erlaubt.
--
-- ABSCHALTEN: die Zeile "- quiz.lua" unter format.html.filters in
-- _quarto.yml entfernen. Die Fragen bleiben dann als gewoehnliche
-- Aufzaehlung stehen und sind weiterhin lesbar.

local stringify = pandoc.utils.stringify

-- Pandoc stellt Aufgabenlisten mit diesen beiden Zeichen dar.
local KAESTCHEN_LEER = "\226\152\144"   -- U+2610
local KAESTCHEN_VOLL = "\226\152\146"   -- U+2612

local hatQuiz = false

-- ---------------------------------------------------------------------------
-- Hilfsfunktionen
-- ---------------------------------------------------------------------------

local function ohneRandleerzeichen(inlines)
  local von, bis = 1, #inlines
  while von <= bis and inlines[von].t == "Space" do von = von + 1 end
  while bis >= von and inlines[bis].t == "Space" do bis = bis - 1 end

  local raus = pandoc.Inlines({})
  for i = von, bis do raus:insert(inlines[i]) end
  return raus
end

-- Trennt an der ersten freistehenden Tilde in Antwort und Erklaerung.
local function teileAnTilde(inlines)
  for i, el in ipairs(inlines) do
    if el.t == "Str" and el.text == "~" then
      local antwort, erklaerung = pandoc.Inlines({}), pandoc.Inlines({})
      for j = 1, i - 1 do antwort:insert(inlines[j]) end
      for j = i + 1, #inlines do erklaerung:insert(inlines[j]) end
      return ohneRandleerzeichen(antwort), ohneRandleerzeichen(erklaerung)
    end
  end
  return ohneRandleerzeichen(inlines), pandoc.Inlines({})
end

-- Liest die Markierung am Zeilenanfang und entfernt sie aus dem Text.
-- Rueckgabe: richtig (true/false/nil wenn keine Markierung gefunden), Rest.
local function leseMarkierung(inlines)
  local erstes = inlines[1]
  if erstes and erstes.t == "Str" then
    if erstes.text == KAESTCHEN_VOLL or erstes.text == KAESTCHEN_LEER then
      local rest = pandoc.Inlines({})
      for i = 2, #inlines do rest:insert(inlines[i]) end
      return erstes.text == KAESTCHEN_VOLL, ohneRandleerzeichen(rest)
    end
  end

  -- Fallback, falls Aufgabenlisten nicht als Kaestchen ankommen: [x] oder [ ]
  local ganz = stringify(inlines)
  local marke = ganz:match("^%[%s*([xX]?)%s*%]")
  if marke then
    local rest = pandoc.Inlines({})
    local uebersprungen = false
    for i, el in ipairs(inlines) do
      if not uebersprungen then
        if el.t == "Str" and el.text:match("%]$") then uebersprungen = true end
      else
        rest:insert(el)
      end
    end
    return marke ~= "", ohneRandleerzeichen(rest)
  end

  return nil, inlines
end

-- ---------------------------------------------------------------------------
-- Aufbau der Antwortliste
-- ---------------------------------------------------------------------------

local function baueOption(bloecke, nummer)
  -- Der Antworttext steht im ersten Block des Listenpunkts.
  local erster = bloecke[1]
  if not erster or not erster.content then return nil, false end

  local richtig, rest = leseMarkierung(erster.content)
  local antwort, erklaerung = teileAnTilde(rest)

  local inhalt = pandoc.Blocks({})

  inhalt:insert(pandoc.Div(
    pandoc.Plain(antwort),
    pandoc.Attr("", { "quiz__antwort" }, {
      ["role"] = "button",
      ["tabindex"] = "0",
      ["data-nummer"] = tostring(nummer),
    })))

  if #erklaerung > 0 then
    inhalt:insert(pandoc.Div(
      pandoc.Plain(erklaerung),
      pandoc.Attr("", { "quiz__erklaerung" })))
  end

  local option = pandoc.Div(inhalt, pandoc.Attr("", { "quiz__option" }, {
    ["data-richtig"] = richtig and "1" or "0",
  }))

  return option, richtig == true
end

local function baueQuiz(el)
  local frage = pandoc.Blocks({})
  local liste = nil

  for _, block in ipairs(el.content) do
    if block.t == "BulletList" and not liste then
      liste = block
    else
      frage:insert(block)
    end
  end

  -- Ohne Antwortliste bleibt der Block, wie er ist.
  if not liste then return el end

  local optionen = pandoc.Blocks({})
  local hatRichtige = false

  for nummer, punkt in ipairs(liste.content) do
    local option, richtig = baueOption(punkt, nummer)
    if option then
      optionen:insert(option)
      hatRichtige = hatRichtige or richtig
    end
  end

  if #optionen == 0 then return el end

  -- Sichtbarer Hinweis statt stiller Fehlfunktion: eine Frage ohne markierte
  -- Loesung waere im Browser nicht loesbar und der Grund nicht erkennbar.
  if not hatRichtige then
    optionen:insert(pandoc.Div(
      pandoc.Plain(pandoc.Str("Achtung: In dieser Frage ist keine Antwort mit [x] markiert.")),
      pandoc.Attr("", { "quiz__warnung" })))
  end

  hatQuiz = true

  local inhalt = pandoc.Blocks({})
  inhalt:insert(pandoc.Div(frage, pandoc.Attr("", { "quiz__frage" })))
  inhalt:insert(pandoc.Div(optionen, pandoc.Attr("", { "quiz__optionen" })))

  local attr = el.attr
  attr.classes = pandoc.List({ "quiz" })
  return pandoc.Div(inhalt, attr)
end

-- ---------------------------------------------------------------------------
-- Das Skript, das die Antworten anklickbar macht
-- ---------------------------------------------------------------------------

local SKRIPT = [[
<script>
(function () {
  function auswerten(option, quiz) {
    var richtig = option.getAttribute("data-richtig") === "1";
    option.classList.add(richtig ? "is-richtig" : "is-falsch");
    option.classList.add("is-beantwortet");

    if (richtig) {
      quiz.classList.add("is-geloest");
      // Bei richtiger Antwort die uebrigen Erklaerungen mit aufdecken,
      // damit auch klar wird, warum die anderen nicht stimmen.
      quiz.querySelectorAll(".quiz__option").forEach(function (o) {
        o.classList.add("is-beantwortet");
        if (o !== option) { o.classList.add("is-verworfen"); }
      });
    }
  }

  document.querySelectorAll(".quiz").forEach(function (quiz) {
    quiz.querySelectorAll(".quiz__antwort").forEach(function (knopf) {
      var option = knopf.closest(".quiz__option");

      knopf.addEventListener("click", function () { auswerten(option, quiz); });
      knopf.addEventListener("keydown", function (e) {
        if (e.key === "Enter" || e.key === " ") {
          e.preventDefault();
          auswerten(option, quiz);
        }
      });
    });
  });
})();
</script>
]]

-- ---------------------------------------------------------------------------
-- Filter
-- ---------------------------------------------------------------------------

return {
  {
    Div = function(el)
      if not quarto.doc.is_format("html:js") then return el end
      for _, klasse in ipairs(el.classes) do
        if klasse == "quiz" then return baueQuiz(el) end
      end
      return el
    end,
  },
  {
    -- Das Skript nur auf Seiten einbinden, die tatsaechlich Fragen enthalten.
    Pandoc = function(doc)
      if hatQuiz and quarto.doc.is_format("html:js") then
        quarto.doc.include_text("after-body", SKRIPT)
      end
      return doc
    end,
  },
}
