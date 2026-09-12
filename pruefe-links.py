# -*- coding: utf-8 -*-
"""Prueft, ob jeder Querverweis zwischen Seiten ein vorhandenes Ziel hat.

Hintergrund: Quarto meldet einen toten internen Link nicht als Fehler, der
Build bleibt gruen und die Seite hat einen Verweis ins Leere. Geprueft werden
Links auf .qmd-Dateien, ihre Anker und die Bilder unter assets/.

Aufruf:
    python pruefe-links.py              # ganzes Repo
    python pruefe-links.py daten        # nur ein Verzeichnis

Rueckgabewert 1, wenn ein Ziel fehlt.
"""
import io
import os
import re
import sys

# [Text](ziel.qmd) und [Text](../ordner/ziel.qmd#anker)
LINK = re.compile(r"\]\(([^)\s]+\.qmd)(#[^)\s]*)?\)")
BILD = re.compile(r"\]\((/?(?:assets|bilder)/[^)\s]+)\)")
UEBERSCHRIFT = re.compile(r"^#{1,6}\s+(.+?)\s*$", re.M)

AUSGENOMMEN = (".git", "_freeze", "docs", ".quarto", "cas-")


def anker(titel):
    """Bildet die Kennung, die Pandoc aus einer Ueberschrift macht."""
    text = re.sub(r"\{[^}]*\}", "", titel)           # Attribute entfernen
    text = re.sub(r"[`*_\[\]]", "", text).strip().lower()
    text = text.replace("ä", "a").replace("ö", "o").replace("ü", "u")
    text = text.replace("ß", "ss")
    text = re.sub(r"[^\w\s-]", "", text)
    return re.sub(r"\s+", "-", text)


def sammle_anker(pfad):
    quelle = io.open(pfad, encoding="utf-8").read()
    # Ueberschriften in Codebloecken zaehlen nicht
    ohne_code = re.sub(r"(?s)```.*?```", "", quelle)
    return {anker(t) for t in UEBERSCHRIFT.findall(ohne_code)}


def main():
    wurzel = sys.argv[1] if len(sys.argv) > 1 else "."
    seiten = []
    for ordner, _, dateien in os.walk(wurzel):
        if any(teil in ordner for teil in AUSGENOMMEN):
            continue
        seiten += [os.path.join(ordner, d) for d in dateien if d.endswith(".qmd")]

    treffer = 0
    for pfad in sorted(seiten):
        quelle = io.open(pfad, encoding="utf-8").read()
        hier = os.path.dirname(pfad)

        for ziel, sprung in LINK.findall(quelle):
            voll = os.path.normpath(os.path.join(hier, ziel))
            if not os.path.exists(voll):
                print(f"{pfad}: Ziel fehlt -> {ziel}")
                treffer += 1
            elif sprung and sprung != "#":
                if sprung[1:] not in sammle_anker(voll):
                    print(f"{pfad}: Anker fehlt -> {ziel}{sprung}")
                    treffer += 1

        for bild in BILD.findall(quelle):
            voll = bild[1:] if bild.startswith("/") else os.path.normpath(
                os.path.join(hier, bild))
            if not os.path.exists(voll):
                print(f"{pfad}: Bild fehlt -> {bild}")
                treffer += 1

    if treffer:
        print(f"\n{treffer} tote Verweise gefunden.")
        return 1

    print(f"{len(seiten)} Seiten geprueft, alle Verweise zeigen auf etwas.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
