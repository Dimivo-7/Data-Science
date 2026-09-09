-- Erzeugt den Platzhalterhinweis aus dem Frontmatter-Feld `stand`.
-- So steht der Hinweis an genau einer Stelle im Repo und nicht in jeder Datei.
-- `stand: fertig` oder ein fehlendes Feld ergeben keinen Hinweis.

local texte = {
  geruest = "Diese Seite ist ein Gerüst. Die Abschnitte stehen, der Inhalt fehlt noch.",
  entwurf = "Diese Seite ist ein Entwurf. Der Inhalt steht, ist aber noch nicht durchgeprüft."
}

function Pandoc(doc)
  if doc.meta.stand == nil then
    return nil
  end

  local text = texte[pandoc.utils.stringify(doc.meta.stand)]
  if text == nil then
    return nil
  end

  local hinweis = pandoc.Div(pandoc.read(text).blocks,
                             pandoc.Attr("", { "placeholder-notice" }))
  table.insert(doc.blocks, 1, hinweis)
  return doc
end
