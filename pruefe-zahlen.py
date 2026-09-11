"""Prueft, ob jede Dezimalzahl im Fliesstext einer Seite auch in der
tatsaechlichen Chunk-Ausgabe vorkommt.

Hintergrund: Ein gruener Build sagt nur, dass der Code laeuft -- nicht, dass
die Zahlen im Text zu den Zahlen in der Ausgabe passen. Genau dort sind in
diesem Repo die meisten Fehler entstanden (siehe build-fehler.md).

Geprueft werden nur Zahlen mit mindestens zwei Nachkommastellen. Ganze Zahlen
und Werte mit einer Nachkommastelle sind zu oft Theoriewerte, Jahreszahlen
oder Stichprobenumfaenge, als dass eine Pruefung Sinn ergaebe.

Aufruf:
    python pruefe-zahlen.py                     # alle Seiten
    python pruefe-zahlen.py statistik/tests     # nur ein Verzeichnis
    python pruefe-zahlen.py <datei.qmd>         # eine Seite
"""

import glob
import io
import json
import os
import re
import sys

# Zahlen, die praktisch immer Theorie sind und nicht aus einer Ausgabe stammen.
BEKANNTE_THEORIEWERTE = {
    "1.96", "2.58", "1.645", "0.05", "0.01", "0.10", "0.025", "0.975",
    "0.95", "0.99", "0.90", "0.50", "0.80", "0.20", "3.84",
}

ZAHL = re.compile(r"-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?")
TEXTZAHL = re.compile(r"(?<![\w.])(\d+\.\d{2,})(?![\w])")


def nur_fliesstext(inhalt):
    """Entfernt Frontmatter, Code-Chunks, Codebloecke und Inline-Code."""
    if inhalt.startswith("---"):
        ende = inhalt.find("\n---", 3)
        if ende > 0:
            inhalt = inhalt[ende + 4:]
    inhalt = re.sub(r"^```.*?^```", "", inhalt, flags=re.S | re.M)
    inhalt = re.sub(r"`[^`\n]*`", "", inhalt)
    return inhalt


def ausgabe_zahlen(freeze_datei):
    """Alle Zahlen, die in irgendeiner Chunk-Ausgabe der Seite vorkommen."""
    with io.open(freeze_datei, encoding="utf-8") as f:
        roh = f.read()
    json.loads(roh)   # nur als Formatpruefung
    werte = set()
    for treffer in ZAHL.findall(roh):
        try:
            werte.add(float(treffer))
        except ValueError:
            continue
    return werte


def passt(zahl_text, werte):
    """Stimmt die Textzahl mit irgendeinem Ausgabewert ueberein?

    Zugelassen sind: direkte Uebereinstimmung nach Rundung auf die im Text
    gezeigten Stellen, Prozentangaben (Faktor 100 in beide Richtungen) und das
    Vorzeichen. Das Vorzeichen wird ignoriert, weil im Text das typografische
    Minuszeichen steht und die Richtung ohnehin im Satz erklaert wird.
    """
    stellen = len(zahl_text.split(".")[1])
    ziel = round(float(zahl_text), stellen)
    for faktor in (1.0, 0.01, 100.0):
        for wert in werte:
            try:
                if round(abs(wert) * faktor, stellen) == ziel:
                    return True
            except (ValueError, OverflowError):
                continue
    return False


def pruefe(qmd):
    rel = qmd.replace("\\", "/")[:-4]
    freeze = f"_freeze/{rel}/execute-results/html.json"
    if not os.path.exists(freeze):
        return None, []
    werte = ausgabe_zahlen(freeze)
    text = nur_fliesstext(io.open(qmd, encoding="utf-8").read())
    offen = []
    for zahl in sorted(set(TEXTZAHL.findall(text))):
        if zahl in BEKANNTE_THEORIEWERTE:
            continue
        if not passt(zahl, werte):
            offen.append(zahl)
    return len(set(TEXTZAHL.findall(text))), offen


def main():
    ziel = sys.argv[1] if len(sys.argv) > 1 else "statistik"
    if ziel.endswith(".qmd"):
        seiten = [ziel]
    else:
        seiten = sorted(glob.glob(os.path.join(ziel, "**", "*.qmd"), recursive=True))
    seiten = [s for s in seiten if not s.endswith("index.qmd")]

    sauber, mit_offenen, ohne_freeze = [], [], []
    for qmd in seiten:
        anzahl, offen = pruefe(qmd)
        if anzahl is None:
            ohne_freeze.append(qmd)
        elif offen:
            mit_offenen.append((qmd, anzahl, offen))
        else:
            sauber.append((qmd, anzahl))

    for qmd, anzahl, offen in mit_offenen:
        print(f"{qmd}: {len(offen)} von {anzahl} Zahlen nicht in der Ausgabe gefunden")
        print("   " + "  ".join(offen[:25]) + ("  ..." if len(offen) > 25 else ""))
    if ohne_freeze:
        print("\nOhne Freeze (noch nie gebaut oder ohne Code):")
        for qmd in ohne_freeze:
            print("  ", qmd)
    print(f"\n{len(sauber)} Seiten ohne Befund, {len(mit_offenen)} mit offenen Zahlen, "
          f"{len(ohne_freeze)} ohne Freeze.")
    return 1 if mit_offenen else 0


if __name__ == "__main__":
    sys.exit(main())
