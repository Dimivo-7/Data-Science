# -*- coding: utf-8 -*-
"""Prueft vor dem Push, ob jede Seite die Bibliotheken laedt, die sie benutzt.

Hintergrund: Quarto laeuft nicht lokal, der GitHub-Build ist der einzige Test,
und ein einziger fehlender Import bricht das Rendern der ganzen Seite ab. Der
haeufigste Fall ist ein Beispiel, das von einer Nachbarseite uebernommen wurde,
deren Setup-Chunk mehr importiert.

Geprueft wird pro Datei, nicht pro Chunk: Quarto fuehrt alle Chunks einer Seite
in derselben Sitzung aus, ein Import im Setup-Chunk genuegt also.

Aufruf:
    python pruefe-chunks.py                # ganzes Repo
    python pruefe-chunks.py statistik      # nur ein Unterverzeichnis

Rueckgabewert 1, wenn etwas fehlt. Damit laesst sich das Skript auch in einen
Pre-Push-Hook haengen.
"""
import io
import os
import re
import sys

# Kuerzel -> Zeichenkette, die im Quelltext der Seite vorkommen muss, damit das
# Kuerzel definiert ist.
#
# Gesucht wird mit Wortgrenze davor, sonst schlaegt "sm.stats.diagnostic" faelsch
# als fehlendes scipy an und "stats.norm.ppf" als fehlendes norm.
PYTHON_KUERZEL = {
    "np.": "import numpy as np",
    "pd.": "import pandas as pd",
    "plt.": "import matplotlib.pyplot as plt",
    "sm.": "import statsmodels.api as sm",
    "smf.": "import statsmodels.formula.api as smf",
    "pg.": "import pingouin as pg",
    "stats.": "from scipy import stats",
    "sns.": "import seaborn as sns",
    "PCA(": "from sklearn.decomposition import PCA",
    "StandardScaler(": "from sklearn.preprocessing import StandardScaler",
    "norm.ppf": "from scipy.stats import norm",
}

# R-Funktion -> Paket, das geladen sein muss. Basis-R steht hier nicht drin.
R_FUNKTIONEN = {
    "ggplot(": "ggplot2",
    "bptest(": "lmtest",
    "vif(": "car",
    "cohens_d(": "effectsize",
    "eta_squared(": "effectsize",
    "pwr.t.test(": "pwr",
    "Surv(": "survival",
    "survfit(": "survival",
    "coxph(": "survival",
    "kmeans(": None,          # stats, immer da
    "auto.arima(": "forecast",
    "adf.test(": "tseries",
    "fa(": "psych",
}

CHUNK = re.compile(r"^```\{(r|python)[^}]*\}\n(.*?)^```", re.S | re.M)


def pruefe(pfad):
    quelle = io.open(pfad, encoding="utf-8").read()
    fehler = []

    for sprache, code in CHUNK.findall(quelle):
        if sprache == "python":
            for kuerzel, noetig in PYTHON_KUERZEL.items():
                muster = r"(?<![\w.])" + re.escape(kuerzel)
                if re.search(muster, code) and noetig not in quelle:
                    fehler.append(f"benutzt {kuerzel!r}, aber {noetig!r} fehlt")
        else:
            for funktion, paket in R_FUNKTIONEN.items():
                if paket is None or funktion not in code:
                    continue
                geladen = (f"library({paket})" in quelle
                           or f"{paket}::" in code)
                if not geladen:
                    fehler.append(
                        f"benutzt {funktion!r}, aber library({paket}) fehlt "
                        f"(oder {paket}:: davorsetzen)")

    return sorted(set(fehler))


def main():
    wurzel = sys.argv[1] if len(sys.argv) > 1 else "."
    treffer = 0

    for ordner, _, dateien in os.walk(wurzel):
        if any(teil in ordner for teil in (".git", "_freeze", "docs", ".quarto")):
            continue
        for datei in sorted(dateien):
            if not datei.endswith(".qmd"):
                continue
            pfad = os.path.join(ordner, datei)
            for fehler in pruefe(pfad):
                print(f"{pfad}: {fehler}")
                treffer += 1

    if treffer:
        print(f"\n{treffer} fehlende Voraussetzung(en) gefunden.")
        return 1

    print("Alle Seiten laden, was sie benutzen.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
