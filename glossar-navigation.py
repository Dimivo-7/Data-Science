"""Entfernt Glossar-Markierungen aus der Navigation der fertigen HTML-Seiten.

glossary.lua markiert Begriffe im Inhalt. Quarto uebernimmt Seitentitel und
Ueberschriften aber auch in Seitenleiste, Brotkrumenpfad, Kopfbereich und
Reiterbeschriftungen, und zwar ausserhalb dessen, was ein Lua-Filter sieht.
Dort standen die Markierungen bisher im HTML und wurden nur per CSS
unsichtbar gemacht.

Dieses Skript laeuft als post-render (siehe _quarto.yml) und packt die
Markierungen nur in diesen Bereichen aus. Der Inhalt der Seite bleibt
unberuehrt. Nur Standardbibliothek, damit es im Build ohne Installation
laeuft.
"""

import os
import re
import sys
from pathlib import Path

# Bereiche, in denen kein Tooltip stehen soll. Nicht gierig, keiner davon
# enthaelt ein gleichnamiges Element in sich.
BEREICHE = [
    re.compile(r'<nav id="quarto-sidebar".*?</nav>', re.S),
    re.compile(r'<nav id="TOC".*?</nav>', re.S),
    re.compile(r'<nav class="quarto-page-breadcrumbs.*?</nav>', re.S),
    re.compile(r"<header.*?</header>", re.S),
    re.compile(r'<ul class="nav nav-tabs".*?</ul>', re.S),
    re.compile(r'<nav class="page-navigation".*?</nav>', re.S),
    re.compile(r"<title>.*?</title>", re.S),
]

# Ein Glossar-Span enthaelt nur Text und Leerzeichen, nie ein weiteres Element.
# Spitze Klammern im data-def sind von Pandoc als &lt; &gt; maskiert.
SPAN = re.compile(r'<span class="glossary-term"[^>]*>(.*?)</span>', re.S)


def bereinige(html):
    anzahl = 0

    def auspacken(treffer):
        nonlocal anzahl
        teil, n = SPAN.subn(r"\1", treffer.group(0))
        anzahl += n
        return teil

    for muster in BEREICHE:
        html = muster.sub(auspacken, html)
    return html, anzahl


def dateien():
    # Bei einem Teil-Render nennt Quarto die geschriebenen Dateien, sonst wird
    # das ganze Ausgabeverzeichnis durchgegangen.
    liste = os.environ.get("QUARTO_PROJECT_OUTPUT_FILES", "").strip()
    if liste:
        return [Path(z) for z in liste.splitlines() if z.endswith(".html")]
    ziel = Path(os.environ.get("QUARTO_PROJECT_OUTPUT_DIR", "docs"))
    return sorted(ziel.rglob("*.html"))


def main(pfade):
    gesamt = seiten = 0
    for pfad in pfade:
        if not pfad.is_file():
            continue
        alt = pfad.read_text(encoding="utf-8")
        neu, n = bereinige(alt)
        if n:
            pfad.write_text(neu, encoding="utf-8")
            gesamt += n
            seiten += 1
    print(f"glossar-navigation: {gesamt} Markierungen auf {seiten} Seiten entfernt")


if __name__ == "__main__":
    main([Path(a) for a in sys.argv[1:]] or dateien())
