# -*- coding: utf-8 -*-
"""Hilfsfunktionen fuer die Migration alter Lektionsseiten in die Themenstruktur.

Temporaer, wird nach Abschluss der Migration geloescht.
"""
import io, os, re, subprocess

ZIEL = {
 ("pyfr", 1): ("programmierung/python-grundlagen.qmd", "Python-Grundlagen"),
 ("pyfr", 2): ("programmierung/python-funktionen-module.qmd", "Funktionen und Module in Python"),
 ("pyfr", 3): ("programmierung/python-objektorientierung.qmd", "Objektorientierung in Python"),
 ("pyfr", 4): ("programmierung/python-exceptions-io.qmd", "Fehlerbehandlung und Dateizugriff"),
 ("pyfr", 5): ("programmierung/pakete-umgebungen.qmd", "Pakete und Umgebungen"),
 ("pyfr", 6): ("programmierung/numpy-scipy.qmd", "NumPy und SciPy"),
 ("pyfr", 7): ("programmierung/pandas.qmd", "pandas"),
 ("pyfr", 8): ("visualisierung/matplotlib.qmd", "matplotlib"),
 ("pyfr", 9): ("werkzeuge/linux-shell.qmd", "Linux und Shell"),
 ("pyfr", 10): ("werkzeuge/git.qmd", "Git"),
 ("pyfr", 11): ("werkzeuge/docker-virtualisierung.qmd", "Docker und Virtualisierung"),
 ("pyfr", 12): ("daten/sql.qmd", "SQL"),
 ("esds", 1): ("programmierung/r-grundlagen.qmd", "R-Grundlagen"),
 ("esds", 2): ("daten/data-wrangling.qmd", "Data Wrangling"),
 ("esds", 3): ("statistik/grundlagen/skalenniveaus.qmd", "Skalenniveaus"),
 ("esds", 4): ("statistik/grundlagen/lage-streuungsmasse.qmd", "Lage- und Streuungsmasse"),
 ("esds", 5): ("visualisierung/ggplot2.qmd", "ggplot2"),
 ("esds", 6): ("statistik/grundlagen/explorative-datenanalyse.qmd", "Explorative Datenanalyse"),
 ("esds", 7): ("statistik/wahrscheinlichkeit/kombinatorik-wahrscheinlichkeit.qmd", "Kombinatorik und Wahrscheinlichkeit"),
 ("esds", 8): ("statistik/wahrscheinlichkeit/bedingte-wahrscheinlichkeit-bayes.qmd", "Bedingte Wahrscheinlichkeit und Bayes"),
 ("esds", 9): ("statistik/wahrscheinlichkeit/diskrete-verteilungen.qmd", "Diskrete Verteilungen"),
 ("esds", 10): ("statistik/wahrscheinlichkeit/stetige-verteilungen.qmd", "Stetige Verteilungen"),
 ("esds", 11): ("statistik/grundlagen/korrelation.qmd", "Korrelation"),
 ("esds", 12): ("statistik/inferenz/schaetzen-konfidenzintervalle.qmd", "Schätzen und Konfidenzintervalle"),
 ("esds", 13): ("statistik/inferenz/hypothesentests-grundlagen.qmd", "Hypothesentests: Grundlagen"),
 ("esds", 14): ("statistik/tests/chi-quadrat-tests.qmd", "Chi-Quadrat-Tests"),
}


def frontmatter(pfad):
    """Frontmatter der bereits angelegten Zielseite lesen."""
    return io.open(pfad, encoding="utf-8").read().split("---\n")[1]


def links_umschreiben(text, modul, zielpfad):
    """[L3 - Titel](lesson3.qmd) und [ESDS L5](../esds/lesson5.qmd) auf neue Pfade."""
    def ersatz(m):
        quelle = m.group("mod") or modul
        nummer = int(m.group("nr"))
        if (quelle, nummer) not in ZIEL:
            return m.group(0)
        ziel, titel = ZIEL[(quelle, nummer)]
        rel = os.path.relpath(ziel, os.path.dirname(zielpfad)).replace("\\", "/")
        return "[%s](%s)" % (titel, rel)
    muster = re.compile(
        r"\[[^\]]*\]\((?:\.\./(?P<mod>pyfr|esds)/)?lesson(?P<nr>\d+)\.qmd\)")
    return muster.sub(ersatz, text)


def quelltext(modul, nummer):
    return io.open("cas-grundlagen/%s/lesson%d.qmd" % (modul, nummer),
                   encoding="utf-8").read()


def schreibe(ziel, text, modul):
    fm = frontmatter(ziel).replace("stand: geruest", "stand: entwurf")
    io.open(ziel, "w", encoding="utf-8", newline="\n").write(
        "---\n" + fm + "---\n\n" + links_umschreiben(text, modul, ziel).strip("\n") + "\n")
    print("geschrieben:", ziel)


def entferne(modul, nummer):
    pfad = "cas-grundlagen/%s/lesson%d.qmd" % (modul, nummer)
    subprocess.run(["git", "rm", "-q", pfad], check=True)
    print("entfernt:", pfad)


def migriere(modul, nummer, ersetzungen=()):
    """Eine Lektion 1:1 auf ihre Zielseite verschieben."""
    ziel, _ = ZIEL[(modul, nummer)]
    rumpf = quelltext(modul, nummer).split("---\n", 2)[2]
    rumpf = rumpf.replace("## Kernideen aus dem Kurs", "## Kernideen")
    rumpf = links_umschreiben(rumpf, modul, ziel)
    for a, b in ersetzungen:
        if a not in rumpf:
            raise SystemExit("nicht gefunden in %s/%d: %r" % (modul, nummer, a[:60]))
        rumpf = rumpf.replace(a, b)
    fm = frontmatter(ziel).replace("stand: geruest", "stand: entwurf")
    io.open(ziel, "w", encoding="utf-8", newline="\n").write("---\n" + fm + "---\n" + rumpf)
    entferne(modul, nummer)
    print("migriert ->", ziel)
