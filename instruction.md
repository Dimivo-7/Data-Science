# Anleitung: Umbau der Notizseite auf eine thematische Struktur

Diese Datei ersetzt `instruction.md`. Sie beschreibt, wie die Website neu
aufgebaut wird, wie Seiten aussehen müssen und in welcher Reihenfolge der Umbau
passiert. Sie richtet sich an mich selbst **und** an Claude Code, das den Umbau
und die Seiten umsetzt.

Was sich gegenüber `instruction.md` **nicht** ändert, steht in Abschnitt 13 und
gilt weiterhin (Tabsets, Chunks, Glossar, Quiz, Formatierungsbausteine).

Stand: 08.09.2026, überarbeitet nach kritischer Durchsicht (Listings statt
Handkarten, Freeze im Build, Pakete von Anfang an, Seitentyp pro Seite,
Herkunft als Frontmatter-Feld statt Tag, Lesepfade, Fragen-Seiten je Bereich).

---

## 1. Warum der Umbau

Die bisherige Seite ist nach Kursen und Lektionen gegliedert (`cas-grundlagen/
esds/lesson9.qmd`). Das hat drei Probleme:

- Kurse überschneiden sich. Verteilungen, Hypothesentests und Regression kommen
  in mehreren Kursen vor und würden mehrfach, aber jedes Mal etwas anders
  dokumentiert.
- Gesucht wird nach Thema, nicht nach Lektion. In zwei Jahren lautet die Frage
  "wie interpretiere ich den Output einer logistischen Regression", nicht "was
  war in Lektion 9".
- Die Seite ist an eine Schule und ein Studienprogramm gebunden. Sie soll eine
  neutrale Data-Science-Nachschlageseite sein.

Deshalb gilt neu:

| Bisher | Neu |
|---|---|
| Ordner je Kurs, Datei je Lektion | Ordner je Themenbereich, Datei je Thema |
| Titel `L9 – Diskrete Verteilungen` | Titel `Diskrete Verteilungen` |
| Kurs steht in der Navigation | Kurs steht nur im Frontmatter-Feld `quelle`, unsichtbar auf der Seite |
| Startseite mit Modulkarten | Übersichtsseite mit allen Themen und Lesepfaden, automatisch aus dem Frontmatter erzeugt |
| Eine Seitenschablone für alles | Vier Seitentypen: Konzept, Methode, Werkzeug, Referenz |
| Kein zentrales Befehlsverzeichnis | Befehlsreferenz R und Python, thematisch sortiert |
| Handgepflegte Karten in `index.qmd` | Quarto-Listings, Karten entstehen aus dem Frontmatter |
| Jeder Push rechnet alles neu | `freeze: auto`, nur geänderte Seiten werden neu gerechnet |

Zwei Vorbilder für Aufbau und Didaktik (nicht für den Inhalt): die Seiten
`digital-ai-finance.github.io/statistical-data-analysis` und
`digital-ai-finance.github.io/data-science`. Übernommen werden daraus der
"Start here"-Einstieg mit Lesepfaden, Verständnisfragen je Thema plus
schwerere übergreifende Fragen je Bereich, und eine Statusübersicht. Nicht
übernommen werden Folien-PDFs und Chart-Galerien ohne Erklärtext; diese Seite
erklärt und interpretiert, sie sammelt nicht.

---

## 2. Neutralität: Was nirgends mehr vorkommen darf

Die Seite ist eine persönliche Data-Science-Nachschlageseite und sonst nichts.
Deshalb dürfen folgende Begriffe **weder in Seiten noch in `_quarto.yml`,
`index.qmd`, `README.md`, Footer, Navbar oder Beschreibungen** vorkommen:

- Schul- und Programmnamen: `FFHS`, `MAS`, `CAS`, `DAS`, `Fernfachhochschule`
- Studienorganisation: `ECTS`, `Semester`, `Semesterarbeit`, `Prüfung` (im
  Sinn von Examen), `Präsenz`, `PVA`, `Moodle`, `Dozent`, `Leistungsnachweis`,
  `Modul`
- Kurscodes im Fliesstext, in Titeln, Tags oder Ordnernamen: `PYFR`, `ESDS`,
  `STATDA`, `DAVI`. Erlaubt sind sie **nur** im Frontmatter-Feld `quelle`
  (Abschnitt 6), das auf der Seite nicht angezeigt wird.
- Lektionsnummern: `L1`, `Lektion 3`, `lesson`

Ersatzformulierungen:

| Statt | Schreiben |
|---|---|
| "im Kurs", "in der Vorlesung" | weglassen oder "in der Praxis" |
| "Kernideen aus dem Kurs" | "Kernideen" |
| "MAS Data Science – Meine Notizen" | "Data Science Notizen" |
| "Private Notizen zum MAS Data Science (FFHS)" | "Persönliche Notizen" |
| "für die Prüfung wichtig" | "häufige Verwechslung", "typischer Fehler" |

**Prüfung vor jedem Push** (aus dem Repo-Root, `docs/`, `_freeze/` und die
alten `cas-*`-Ordner ausgenommen, solange sie noch existieren):

```bash
grep -rniE "ffhs|\bmas\b|\bcas\b|\bects\b|semester|\bprüfung|\bpruefung|präsenz|praesenz|\bpva\b|moodle|dozent|lektion|lesson|fernfachhochschule" \
  --include="*.qmd" --include="*.yml" --include="*.md" --include="*.scss" --include="*.lua" --include="*.ejs" \
  --exclude-dir=docs --exclude-dir=_freeze --exclude-dir=cas-grundlagen --exclude-dir=cas-statda-davi \
  --exclude-dir=cas-ml --exclude-dir=cas-dea --exclude-dir=cas-ai-eng \
  --exclude-dir=cas-adv-ml --exclude-dir=masterthesis --exclude=instruction.md --exclude=new_instruction.md .
```

Erlaubte Treffer: die Zeile `quelle:` im Frontmatter. Sonst muss das Ergebnis
leer sein. `DAS` (Diploma of Advanced Studies) lässt sich nicht sinnvoll
greppen, weil es mit dem Artikel kollidiert; darauf wird von Hand geachtet.
Treffer wie "Voraussetzungsprüfung" oder "Überprüfung" sind keine Verstösse.

---

## 3. Neue Verzeichnisstruktur

Die neue Struktur wird **neben** der alten aufgebaut. Die alten Ordner
`cas-grundlagen/` und `cas-statda-davi/` bleiben liegen und gerendert, bis die
Migration abgeschlossen ist (Abschnitt 11). Die Platzhalterordner `cas-ml/`,
`cas-dea/`, `cas-ai-eng/`, `cas-adv-ml/`, `masterthesis/` werden nicht mehr
gebraucht und in Phase 3 gelöscht.

Hinter jeder Themenseite steht der Seitentyp: **K** Konzept, **M** Methode,
**W** Werkzeug. Der Typ gilt pro Seite, nicht pro Ordner.

```
mas-data-science-notizen/
├── index.qmd                       Übersicht: Lesepfade, alle Bereiche (Listings)
├── stand.qmd                       Statusübersicht aller Seiten (Listing nach stand)
├── tags.qmd                        Tag-Übersicht (automatisch)
├── glossar.qmd                     Glossar (automatisch aus glossary.yml)
├── links.qmd                       Linkliste
├── new_instruction.md              diese Datei
├── _quarto.yml, styles.scss, glossary.yml, *.lua   bestehend
├── stand.lua                       NEU: Platzhalterhinweis aus stand: erzeugen
├── _templates/                     NEU: Listing-Templates
│   └── karten.ejs                  Kartenraster mit Titel, Beschreibung, Badge
├── _freeze/                        NEU: gerechnete Chunk-Ergebnisse, wird committet
│
├── programmierung/
│   ├── index.qmd
│   ├── fragen.qmd                  übergreifende Fragen zum Bereich
│   ├── python-grundlagen.qmd                W
│   ├── python-funktionen-module.qmd         W
│   ├── python-objektorientierung.qmd        W
│   ├── python-exceptions-io.qmd             W
│   ├── r-grundlagen.qmd                     W
│   ├── numpy-scipy.qmd                      W
│   ├── pandas.qmd                           W
│   ├── pakete-umgebungen.qmd                W   pip, conda, renv, venv
│   └── reproduzierbarkeit.qmd               W   Quarto, Notebooks, Seeds, Projekte
│
├── daten/
│   ├── index.qmd
│   ├── fragen.qmd
│   ├── datenimport-formate.qmd              W   CSV, Excel, JSON, Pickle, Kodierung
│   ├── tidy-data.qmd                        K
│   ├── data-wrangling.qmd                   W   dplyr/tidyr und pandas nebeneinander
│   ├── datum-zeit.qmd                       W
│   ├── datenqualitaet.qmd                   W   fehlende Werte, Duplikate, Plausibilität
│   ├── datenmodellierung.qmd                K   relationales Modell, Normalisierung
│   ├── sql.qmd                              W
│   └── datenbanken-zugriff.qmd              W   DBI/RSQLite, sqlite3, SQLAlchemy
│
├── werkzeuge/
│   ├── index.qmd
│   ├── linux-shell.qmd                      W
│   ├── git.qmd                              W
│   └── docker-virtualisierung.qmd           W
│
├── statistik/
│   ├── index.qmd                   Weg von deskriptiv über Wahrscheinlichkeit zu Modellen
│   ├── fragen.qmd                  schwerere Fragen quer über alle Methoden
│   ├── grundlagen/
│   │   ├── index.qmd
│   │   ├── skalenniveaus.qmd                K
│   │   ├── haeufigkeiten.qmd                K
│   │   ├── lage-streuungsmasse.qmd          K
│   │   ├── korrelation.qmd                  K   Masse; der Test steht unter tests/
│   │   └── explorative-datenanalyse.qmd     K
│   ├── wahrscheinlichkeit/
│   │   ├── index.qmd
│   │   ├── kombinatorik-wahrscheinlichkeit.qmd      K
│   │   ├── bedingte-wahrscheinlichkeit-bayes.qmd    K
│   │   ├── zufallsvariablen.qmd                     K   Erwartungswert, Varianz, Verteilungsfunktion
│   │   ├── diskrete-verteilungen.qmd                K
│   │   ├── stetige-verteilungen.qmd                 K
│   │   ├── normalverteilung-zgws.qmd                K
│   │   └── qq-plots.qmd                             K
│   ├── inferenz/
│   │   ├── index.qmd
│   │   ├── schaetzen-konfidenzintervalle.qmd        M
│   │   ├── hypothesentests-grundlagen.qmd           K   Fehlerarten, p-Wert, Logik
│   │   ├── effektstaerken.qmd                       K
│   │   ├── power-stichprobenumfang.qmd              M   Power-Analyse, n-Planung
│   │   ├── multiples-testen.qmd                     K   Bonferroni, Holm, FDR
│   │   └── bootstrap-resampling.qmd                 M
│   ├── tests/
│   │   ├── index.qmd               Entscheidungsbaum: welcher Test wann
│   │   ├── t-test-eine-stichprobe.qmd               M
│   │   ├── t-test-zwei-stichproben.qmd              M   inkl. Welch
│   │   ├── t-test-gepaart.qmd                       M
│   │   ├── anova.qmd                                M   inkl. Bezug zur Regression, Post-hoc
│   │   ├── chi-quadrat-tests.qmd                    M
│   │   ├── korrelationstests.qmd                    M   Pearson, Spearman, Kendall als Test
│   │   ├── nichtparametrische-tests.qmd             M   Wilcoxon, Mann-Whitney, Kruskal-Wallis
│   │   └── normalitaetstests.qmd                    K   Shapiro, KS, warum Plots oft besser
│   ├── regression/
│   │   ├── index.qmd               Wahl nach Zielvariable: linear, logistisch, Survival
│   │   ├── einfache-lineare-regression.qmd          M
│   │   ├── multiple-lineare-regression.qmd          M
│   │   ├── regressionsdiagnostik.qmd                M   Residuen, VIF, Ausreisser, Hebelwerte
│   │   ├── logistische-regression.qmd               M
│   │   ├── klassifikationsguete.qmd                 M   Konfusionsmatrix, ROC, AUC, Schwellenwert
│   │   └── modellauswahl.qmd                        M   AIC, adj. R², Vergleich, Validierung
│   ├── ueberlebenszeit/
│   │   ├── index.qmd
│   │   ├── zensierung-ueberlebensfunktion.qmd       K
│   │   ├── kaplan-meier.qmd                         M
│   │   ├── log-rank-test.qmd                        M
│   │   └── cox-modell.qmd                           M
│   ├── multivariat/
│   │   ├── index.qmd
│   │   ├── distanzmasse.qmd                         K
│   │   ├── hauptkomponentenanalyse.qmd              M
│   │   ├── faktorenanalyse.qmd                      M
│   │   ├── k-means.qmd                              M
│   │   ├── hierarchisches-clustering.qmd            M
│   │   └── clusterguete.qmd                         M   Silhouette, Ellbogen, Gap
│   └── zeitreihen/
│       ├── index.qmd
│       ├── zeitreihen-grundlagen.qmd                K   Trend, Saison, Zerlegung
│       ├── stationaritaet-acf-pacf.qmd              K   Differenzieren, ADF, ACF/PACF lesen
│       ├── glaettung-einfache-verfahren.qmd         M   gleitender Durchschnitt, exponentiell
│       └── arima-sarima.qmd                         M
│
├── visualisierung/
│   ├── index.qmd
│   ├── fragen.qmd
│   ├── zielbild-audience.qmd                K   Zweck, Publikum, explorativ vs. erklärend
│   ├── wahrnehmung-kodierung.qmd            K
│   ├── diagrammtyp-waehlen.qmd              K
│   ├── ggplot2.qmd                          W
│   ├── matplotlib.qmd                       W
│   ├── seaborn-plotly.qmd                   W
│   ├── farbe.qmd                            K
│   ├── irrefuehrende-darstellungen.qmd      K
│   ├── dashboards-interaktivitaet.qmd       W
│   └── storytelling.qmd                     K
│
└── referenz/
    ├── index.qmd
    ├── r.qmd                       Befehlsreferenz R, thematisch
    └── python.qmd                  Befehlsreferenz Python, thematisch
```

Der Ordnername des Repos bleibt, er ist nicht Teil der Website.

**Brücke zu späteren Bereichen.** `modellauswahl.qmd` (Validierung, Train/Test)
und `klassifikationsguete.qmd` (ROC, AUC) sind bereits die Schnittstelle zu
einem künftigen Bereich `machine-learning/`. Dieser wird erst angelegt, wenn die
erste inhaltliche Seite dafür existiert; die beiden Seiten werden dann von dort
verlinkt, nicht dupliziert.

**Namensregeln**

- Ordner und Dateien: klein, ohne Umlaute (`ae`, `oe`, `ue`, `ss`), ohne
  Leerzeichen, Wörter mit Bindestrich getrennt. Der Dateiname ist das Thema:
  `logistische-regression.qmd`, nie `lesson3.qmd`.
- Jede Übersichtsseite heisst `index.qmd`.
- Maximal zwei Ebenen unter dem Root (`statistik/regression/arima.qmd`).
  Wird ein Bereich grösser, bekommt er Unterordner wie `statistik/`, nicht eine
  dritte Ebene.
- Neue Bereiche werden erst angelegt, wenn die erste inhaltliche Seite dafür
  existiert. Keine leeren Platzhalterordner.
- Kodierung UTF-8, Zeilenenden LF.

**Wann ist etwas eine eigene Seite?** Wenn es in der Praxis eine eigenständige
Entscheidung ist und einen eigenständig zu interpretierenden Output hat.
Einfache und multiple lineare Regression sind deshalb zwei Seiten (Multi-
kollinearität, adjustiertes R² und Modellvergleich gibt es nur bei der zweiten).
Wird eine Seite länger als etwa 3000 Wörter oder braucht sie ein "siehe oben"
für einen anderen Fall, sind es zwei Seiten.

**Wann Methode, wann Konzept?** Methode, wenn es einen Funktionsaufruf mit
einem Output gibt, den man Zeile für Zeile lesen und interpretieren muss
(`lm`, `t.test`, `coxph`, `prcomp`). Konzept, wenn erklärt wird, was etwas
bedeutet oder wie man liest (Distanzmasse, Zensierung, ACF/PACF, p-Wert).

---

## 4. Seitentypen

Es gibt vier Seitentypen. Der Typ steht im Front Matter (`seitentyp:`) und
bestimmt den Aufbau. Alle Seiten sind auf Deutsch, Fachbegriffe dürfen englisch
bleiben. Schweizer Rechtschreibung (`ss` statt `ß`). Keine Gedankenstriche als
Satzzeichen (weder `–` noch `—`); Kommas, Doppelpunkte oder Klammern verwenden.

### 4.1 Front Matter (alle Typen)

```yaml
---
title: "Multiple lineare Regression"
description: "Mehrere Prädiktoren, adjustiertes R², Multikollinearität und wie man den Output liest."
categories: ["Regression", "Modelldiagnostik", "Interpretation", "R", "Python"]
quelle: ["STATDA", "ESDS"]   # Herkunft, wird nicht angezeigt; leer lassen, wenn keine
seitentyp: methode           # konzept | methode | werkzeug | referenz
stand: geruest               # geruest | entwurf | fertig
order: 20                    # Reihenfolge im Listing des Bereichs, Zehnerschritte
---
```

| Feld | Regel |
|---|---|
| `title` | Der Themenname, so wie man ihn nachschlägt. Keine Nummer, kein Kurs, kein Gedankenstrich. Max. ~40 Zeichen, sonst bricht die Sidebar um. |
| `description` | Ein Satz, max. ~120 Zeichen. Erscheint in Listings, Karten und der Tag-Übersicht. Das ist der Text, den die Übersicht zeigt; er wird nirgends von Hand wiederholt. |
| `categories` | 3 bis 6 Tags nach Abschnitt 6. Keine Kurscodes. |
| `quelle` | Liste der Kurse, aus denen Stoff eingeflossen ist: `PYFR`, `ESDS`, `STATDA`, `DAVI`. Wird nicht als Pill angezeigt und erscheint nicht in der Tag-Wolke; `stand.qmd` kann danach filtern. Leer lassen, wenn der Stoff nicht aus einem Kurs stammt. |
| `seitentyp` | Einer der vier Typen. Übersichtsseiten haben keinen. |
| `stand` | `geruest` (nur Struktur), `entwurf` (Inhalt, noch ungeprüft), `fertig`. `stand.lua` setzt bei `geruest` und `entwurf` automatisch eine `.placeholder-notice` oben auf die Seite; nichts von Hand eintragen. |
| `order` | Ganze Zahl, bestimmt die Reihenfolge im Listing und in der Sidebar des Bereichs. Zehnerschritte, damit sich Seiten einschieben lassen. Fachliche Reihenfolge, nicht Alphabet. |

Übersichtsseiten (`index.qmd`) bekommen weder `categories`, `quelle`,
`seitentyp` noch `stand`.

### 4.2 Konzept-Seite

Für alles, was erklärt, aber nicht als Methode "gerechnet" wird: Skalenniveaus,
Tidy Data, Wahrscheinlichkeit, Verteilungen, Wahrnehmung, Farbe, Distanzmasse,
Zensierung, ACF/PACF. Aufbau wie die bisherigen Grundlagen-Lektionen, mit
umbenanntem ersten Abschnitt:

```markdown
## Kernideen
4 bis 6 Stichpunkte, Begriffe statt Sätze

## Erklärung
Fliesstext mit ###-Zwischentiteln, Formeln, gerechneten Beispielen und
Abbildungen im Text. Beispiele in R und Python (panel-tabset, R zuerst).
Nach jedem inhaltlichen Block 2 bis 3 Quizfragen (.quiz).
Ganz oben eine .note-box mit dem vorausgesetzten Vorwissen, verlinkt.

## Verlinkte Ressourcen
```

### 4.3 Methoden-Seite (Statistik)

Der wichtigste Seitentyp. Er gilt für jede Seite, die in Abschnitt 3 mit **M**
markiert ist.

Der Anspruch: Nach dem Lesen kann ich die Methode auswählen, anwenden, **jeden
Wert im Output benennen und korrekt interpretieren**, und zwar nicht nur im
Lehrbuchfall, sondern auch wenn das Ergebnis unklar ist oder eine Voraussetzung
verletzt ist. Die Methode allein reicht nicht; das Resultat und seine Deutung
sind der Kern der Seite.

Alle Methodenseiten haben **exakt diese Abschnitte in dieser Reihenfolge**:

```markdown
## Kurzsteckbrief
Tabelle: Fragestellung | Zielvariable (Skalenniveau) | Prädiktoren/Gruppen |
Was die Methode liefert | R-Funktion | Python-Funktion | Verwandte Methoden

## Wann diese Methode, wann nicht
Typische Fragestellungen. Bedingungen, unter denen sie passt. Was man
stattdessen nimmt, wenn sie nicht passt (verlinkt), z. B. Welch statt
Student, Spearman statt Pearson, Wilcoxon statt t-Test.

## Grundidee und Modell
Intuition in zwei bis drei Sätzen, dann die Formel, dann jeder Bestandteil
der Formel in einem Satz. Konzeptionell, wie geschätzt wird (keine
Herleitung).

## Voraussetzungen und ihre Prüfung
Je Voraussetzung: was sie bedeutet, wie man sie prüft (Plot oder Test, in R
und Python), was bei Verletzung mit dem Ergebnis passiert, was man dann tut.

## Durchführung in R und Python
Beispieldaten im Chunk selbst erzeugt (Seed!), Modell rechnen, vollständigen
Output anzeigen. Ausführbare Chunks, nicht Listings. R und Python liefern
denselben Fall, damit der Output vergleichbar ist.

## Output lesen
Der vollständige Output (summary() in R, statsmodels- oder pingouin-Tabelle
in Python) Zeile für Zeile. Tabelle je Sprache:
Grösse | Was sie sagt | Faustregel oder Falle
Kein Wert wird ausgelassen, auch nicht Freiheitsgrade, Residual standard
error, Deviance, Log-Likelihood, Konvergenzmeldungen. Unterschiede zwischen
R- und Python-Output werden benannt (andere Bezeichnung, andere Default-
Berechnung, fehlende Grösse).

## Ergebnisse interpretieren
Mindestens drei Szenarien, jedes mit eigenem Chunk (R und Python), eigenem
Output und eigener Interpretation:
  A  Klares Ergebnis: deutlicher Effekt, Voraussetzungen erfüllt
  B  Kein oder schwaches Ergebnis: nicht signifikant, Konfidenzintervall
     um null, geringe Effektstärke. Was man daraus schliessen darf und was
     nicht.
  C  Fallstrick: eine Voraussetzung verletzt oder eine typische Falle
     (Multikollinearität, Ausreisser, kleine Stichprobe, Simpson-Paradox,
     Trennung bei logistischer Regression, Ties bei Kaplan-Meier). Wie man
     es im Output erkennt, wie es das Ergebnis verzerrt, was man tut.
Weitere Szenarien, wo sie die Methode braucht (z. B. Interaktion,
kategorialer Prädiktor mit mehreren Stufen, gepaart vs. ungepaart).
Jedes Szenario endet mit dem Ergebnissatz, wie er in einem Bericht stehen
würde.

## Interpretationsfallen
Was die Zahlen nicht sagen, mit konkretem Beispiel: Signifikanz ist keine
Relevanz, p-Wert ist keine Wahrscheinlichkeit der Nullhypothese, R² ist
keine Modellrichtigkeit, Koeffizient ist keine Kausalität, Konfidenzintervall
ist keine Wahrscheinlichkeit für den wahren Wert.

## Ergebnis berichten
Formulierungsvorlage für den Ergebnissatz mit Platzhaltern, dazu welche
Kennzahlen immer genannt werden (Schätzwert, Konfidenzintervall,
Teststatistik mit Freiheitsgraden, p-Wert, Effektstärke, n). Beispiel für
eine Ergebnistabelle.

## Abgrenzung zu verwandten Methoden
Tabelle: Methode | wann diese statt der hier beschriebenen. Verlinkt.

## Verständnisfragen
3 bis 5 Quizfragen (.quiz), die Interpretation prüfen: Output-Auszug oder
Zahlen zeigen, fragen, was folgt.

## Verlinkte Ressourcen
```

Regeln für die Szenarien:

- Jedes Szenario ist ein **eigener ausführbarer Chunk** mit eigenen Daten, die
  den Fall gezielt erzeugen (für Szenario C etwa zwei stark korrelierte
  Prädiktoren). Die Daten werden so gebaut, dass der Effekt im Output sichtbar
  ist; wie sie gebaut wurden, steht im Text.
- Die Interpretation nennt **konkrete Zahlen aus dem Output** ("das
  Konfidenzintervall von -0.4 bis 0.3 schliesst null ein"), nicht abstrakte
  Regeln.
- R und Python zeigen denselben Fall. Weicht der Python-Output ab (z. B.
  Standardfehler bei `statsmodels` vs. R), wird der Unterschied im Text erklärt.
- Ein Szenario ohne Output ist kein Szenario.

**Python-Vorgabe für Tests und Modelle.** `scipy.stats` liefert bei Tests nur
Statistik und p-Wert; damit lässt sich "Output lesen" nicht füllen. Deshalb:
Tests in Python mit `pingouin` (vollständige Tabelle mit Freiheitsgraden,
Konfidenzintervall, Effektstärke, Power), Modelle mit `statsmodels`
(`summary()`), Überlebenszeit mit `lifelines`, PCA und Clustering mit
`scikit-learn`, EFA mit `factor_analyzer`, Zeitreihen mit `statsmodels.tsa`.
`scipy.stats` nur ergänzend, wo pingouin nichts hat.

### 4.4 Werkzeug-Seite

Für Programmierung, Daten und Werkzeuge (Python-Grundlagen, pandas, Git,
Docker, SQL). Aufbau:

```markdown
## Kernideen

## Erklärung
Wie bei Konzept-Seiten, mit Zwischentiteln, Beispielen in beiden Sprachen
(wo sinnvoll) und Quizfragen.

## Typische Aufgaben
Rezepte: Aufgabe in einem Satz, Lösung in R und Python (panel-tabset).
Genau das, was man beim Arbeiten nachschlägt.

## Verlinkte Ressourcen
```

### 4.5 Referenz-Seite

Für `referenz/r.qmd` und `referenz/python.qmd`. Aufbau siehe Abschnitt 5.

### 4.6 Fragen-Seite je Bereich

`programmierung/fragen.qmd`, `daten/fragen.qmd`, `statistik/fragen.qmd`,
`visualisierung/fragen.qmd`. Sie ersetzen die bisherigen Modulquiz-Seiten.
Aufbau: kurzer Absatz, dann 15 bis 25 Quizfragen (`.quiz`), gruppiert nach
`###`-Themen. Die Fragen wiederholen nicht die Verständnisfragen der
Einzelseiten, sondern prüfen **Verbindungen und Verwechslungen** zwischen
Themen: Welcher Test bei welcher Situation, welches Modell bei welcher
Zielvariable, was unterscheidet PCA von EFA, wann ist ein Chi-Quadrat-Test
falsch. Jede Frage zeigt Zahlen, einen Output-Auszug oder eine Situation. Die
Seiten sind schwerer als die Verständnisfragen und wachsen mit jeder fertigen
Themenseite um zwei bis drei Fragen. Front Matter wie Themenseiten, ohne
`quelle`, `seitentyp: konzept`.

---

## 5. Befehlsreferenz R und Python

Zwei Seiten, `referenz/r.qmd` und `referenz/python.qmd`, mit **identischen
Abschnittstiteln in identischer Reihenfolge**, damit man zwischen den Sprachen
hin- und herspringen kann und die Anker gleich heissen.

Abschnitte:

```
## Umgebung und Pakete
## Datenstrukturen
## Import und Export
## Data Wrangling
## Datum und Zeit
## Zeichenketten
## Deskriptive Statistik
## Verteilungen und Zufallszahlen
## Hypothesentests
## Regression und Modelle
## Überlebenszeitanalyse
## Multivariate Verfahren
## Zeitreihen
## Grafik
## Datenbanken und SQL
## Reproduzierbarkeit
```

Innerhalb jedes Abschnitts eine Tabelle:

| Aufgabe | Befehl | Bemerkung |
|---|---|---|
| Zeilen filtern | `filter(df, x > 3)` | dplyr; Basis-R: `df[df$x > 3, ]` |
| Lineares Modell | `lm(y ~ x1 + x2, data = df)` | Output mit `summary()`, siehe [Multiple lineare Regression](../statistik/regression/multiple-lineare-regression.qmd) |

Regeln:

- Nur Listings (```` ```r ````, ```` ```python ````), keine ausführbaren
  Chunks. Die Referenz rechnet nichts.
- Jede Zeile nennt den Befehl mit den wichtigsten Argumenten, nicht die
  vollständige Signatur.
- Wo es eine Themenseite gibt, ist sie in der Bemerkung verlinkt (erstes
  Vorkommen).
- Basis-R und tidyverse stehen beide, tidyverse zuerst. In Python pandas
  zuerst, NumPy oder Standardbibliothek als Bemerkung. Bei Tests in Python
  pingouin zuerst, scipy als Bemerkung.
- Die Referenz wächst mit den Themenseiten: **Jede neue Methodenseite trägt
  ihre Befehle in beide Referenzen ein.** Das gehört zur Checkliste.
- `referenz/index.qmd` verlinkt beide Seiten und erklärt in drei Sätzen die
  Gliederung.

---

## 6. Tags und Herkunft

Tags beantworten "Wo habe ich das schon mal gehabt?". Regeln:

- **3 bis 6 Tags pro Seite**, nur aus dem Vokabular unten, Schreibweise exakt.
- **Keine Kurscodes als Tag.** Die Herkunft steht im Frontmatter-Feld `quelle`
  (Abschnitt 4.1). Tags sind Pills unter dem Titel und die Tag-Wolke, also das
  Sichtbarste an der Seite; Kurscodes dort würden die Neutralität aushebeln.
  `stand.qmd` bietet einen Filter nach `quelle`, damit die Frage "was kam aus
  welchem Kurs" trotzdem beantwortbar bleibt.
- Kein Tag, der den Bereich der Navigation wiederholt (`Statistik`,
  `Visualisierung` als Tag wären nutzlos).
- Neuer Tag nur, wenn er auf mindestens zwei Seiten vorkommt. Tabelle hier
  ergänzen, dann auf allen Seiten setzen.

| Gruppe | Tags |
|---|---|
| Sprache | `R`, `Python` |
| Bibliotheken | `ggplot2`, `tidyverse`, `matplotlib`, `seaborn`, `plotly`, `pandas`, `NumPy`, `statsmodels`, `pingouin`, `scikit-learn`, `lifelines` |
| Programmierung | `Programmiergrundlagen`, `Tooling`, `Reproduzierbarkeit` |
| Daten | `Data Wrangling`, `Datenqualität`, `SQL`, `Datenbanken`, `Linux` |
| Beschreibende Statistik | `Deskriptive Statistik`, `EDA`, `Korrelation` |
| Wahrscheinlichkeit | `Wahrscheinlichkeit`, `Verteilungen`, `Bayes` |
| Inferenz | `Schätzen`, `Hypothesentests`, `Effektstärke`, `Power`, `Resampling`, `Versuchsplanung`, `A/B-Testing` |
| Modelle | `Regression`, `Logistische Regression`, `Klassifikation`, `Survival-Analyse`, `Zeitreihen`, `Prognose` |
| Multivariat | `Dimensionsreduktion`, `Faktorenanalyse`, `Clustering`, `Distanzmasse` |
| Modellgüte | `Modelldiagnostik`, `Modellvalidierung`, `Interpretation` |
| Visualisierung | `Visualisierung`, `Wahrnehmung`, `Farbe`, `Dashboards`, `Interaktivität`, `Storytelling`, `Kommunikation`, `Visualisierungsethik` |
| KI | `Prompting`, `Sprachmodelle` |
| Betrieb | `Deployment` |

Der Tag `Interpretation` steht auf jeder Methodenseite.

---

## 7. Übersicht, Bereichsseiten, Statusseite: alles aus Listings

**Grundsatz: Keine handgepflegten Karten mehr.** Bei rund 80 Themenseiten
wären das über 150 Kartenblöcke in Haupt- und Bereichsübersichten, die bei
jeder Änderung von `description` oder `stand` nachgeführt werden müssten. Das
ist nach drei Monaten garantiert inkonsistent. Stattdessen erzeugt Quarto die
Karten aus dem Frontmatter der Seiten.

### 7.1 Listing-Template

`_templates/karten.ejs` rendert die vorhandenen Bausteine `.card-grid` und
`.lesson-card` (bleiben in `styles.scss`), pro Seite: Titel als Link,
`description`, und ein Badge nach `stand` (`[Gerüst]`, `[Entwurf]`, keines bei
`fertig`). Die `.lesson-card`-Divs werden nicht mehr von Hand geschrieben.

Aufruf in einer Bereichsseite:

```yaml
---
title: "Regression"
listing:
  - id: seiten
    contents: "*.qmd"
    exclude:
      filename: "index.qmd"
    sort: "order"
    template: ../../_templates/karten.ejs
    fields: [title, description, stand]
---
```

und im Text `::: {#seiten}` `:::` an der Stelle, wo die Karten erscheinen
sollen. Sortierung über `order` aus dem Frontmatter.

### 7.2 `index.qmd`: Einstieg, Lesepfade, Bereiche

```markdown
---
title: "Data Science Notizen"
subtitle: "Persönliche Lern- und Nachschlagenotizen"
listing: (ein Listing je Bereich, contents auf die Ordner, sort: order)
---

Zwei bis drei Sätze: thematisch geordnet, jede Seite ein Thema, Beispiele in
R und Python, Statistik-Methoden mit vollständig interpretiertem Output.

::: {.note-box}
Wie die Seite zu lesen ist: Seitentypen, Tags, Glossar, Befehlsreferenz,
Statusseite.
:::

## Einstieg
Drei Lesepfade als nummerierte Listen von Seitenlinks, jeder mit einem Satz,
für wen er ist:
1. "Von null zur multiplen Regression": Skalenniveaus, Lage- und
   Streuungsmasse, Korrelation, Normalverteilung, Konfidenzintervalle,
   Hypothesentests-Grundlagen, t-Test, einfache Regression, multiple
   Regression, Regressionsdiagnostik
2. "Welchen Test brauche ich": direkt zum Entscheidungsbaum in
   statistik/tests/index.qmd, danach Effektstärken und Ergebnis berichten
3. "Von der Rohdatei zur Grafik": Datenimport, Tidy Data, Data Wrangling,
   Datenqualität, Diagrammtyp wählen, ggplot2 oder matplotlib
Weitere Pfade kommen dazu, wenn Bereiche wachsen (Überlebenszeit, Zeitreihen).

## Programmierung      (Listing)
## Daten               (Listing)
## Werkzeuge           (Listing)
## Statistik           (je Unterbereich ein ### mit eigenem Listing)
## Visualisierung      (Listing)
## Referenz            (zwei Links, kein Listing nötig)
```

Die Übersicht ist damit automatisch vollständig: **jede** Themenseite mit
Frontmatter erscheint. Die alte Startseite mit Modulkarten wird ersetzt.

### 7.3 Bereichsseiten

`statistik/index.qmd`, `statistik/tests/index.qmd` usw. bestehen aus einem
erklärenden Absatz und dem Listing ihres Ordners. Der Absatz erklärt die Logik
des Bereichs: In `statistik/tests/index.qmd` steht ein **Entscheidungsbaum**
(welcher Test bei welchem Skalenniveau, wie vielen Gruppen, gepaart oder
nicht, Voraussetzungen erfüllt oder nicht), in `statistik/regression/index.qmd`
die Wahl zwischen linear, logistisch und Survival nach Zielvariable, in
`statistik/index.qmd` der Weg von deskriptiv über Wahrscheinlichkeit zu
Inferenz und Modellen. Am Ende jeder Bereichsseite ein Link auf die
`fragen.qmd` des Bereichs.

### 7.4 `stand.qmd`: Statusübersicht

Ein Listing über alle Themenseiten (`contents` auf alle Bereichsordner) als
Tabelle mit `title`, Bereich, `seitentyp`, `stand`, `quelle`, sortiert nach
`stand`, mit Filter und Suche (`filter-ui: true`). Damit sieht man auf einen
Blick, was Gerüst, Entwurf und fertig ist, und kann nach `quelle` filtern.
Diese Seite ist der Ersatz für die Kurs-Sicht und steht in der Sidebar unter
"Übersicht".

---

## 8. Navigation (`_quarto.yml`)

```yaml
project:
  type: website
  output-dir: docs
  render:
    - index.qmd
    - stand.qmd
    - tags.qmd
    - glossar.qmd
    - links.qmd
    - programmierung/
    - daten/
    - werkzeuge/
    - statistik/
    - visualisierung/
    - referenz/
    - cas-grundlagen/          # bis Phase 3
    - cas-statda-davi/         # bis Phase 3

execute:
  echo: true
  warning: false
  message: false
  freeze: auto               # nur geänderte Seiten neu rechnen, siehe Abschnitt 9

website:
  title: "Data Science Notizen"
  description: "Persönliche Lern- und Nachschlagenotizen, nicht für Suchmaschinen bestimmt"
  page-footer:
    center: "Persönliche Notizen, nicht öffentlich beworben"
  navbar:
    title: "Data Science"
  sidebar:
    style: docked
    collapse-level: 1
    contents:
      - text: "Übersicht"
        href: index.qmd
      - text: "Stand der Seite"
        href: stand.qmd
      - text: "Tags"
        href: tags.qmd
      - text: "Glossar"
        href: glossar.qmd
      - text: "Linkliste"
        href: links.qmd
      - section: "Programmierung"
        href: programmierung/index.qmd
        contents:
          - auto: "programmierung/*.qmd"
      - section: "Daten"
        href: daten/index.qmd
        contents:
          - auto: "daten/*.qmd"
      - section: "Werkzeuge"
        href: werkzeuge/index.qmd
        contents:
          - auto: "werkzeuge/*.qmd"
      - section: "Statistik"
        href: statistik/index.qmd
        contents:
          - text: "Übergreifende Fragen"
            href: statistik/fragen.qmd
          - section: "Grundlagen"
            href: statistik/grundlagen/index.qmd
            contents:
              - auto: "statistik/grundlagen/*.qmd"
          - section: "Wahrscheinlichkeit"
            href: statistik/wahrscheinlichkeit/index.qmd
            contents:
              - auto: "statistik/wahrscheinlichkeit/*.qmd"
          - section: "Inferenz"
          - section: "Tests"
          - section: "Regression"
          - section: "Überlebenszeit"
          - section: "Multivariat"
          - section: "Zeitreihen"
      - section: "Visualisierung"
        href: visualisierung/index.qmd
        contents:
          - auto: "visualisierung/*.qmd"
      - section: "Referenz"
        href: referenz/index.qmd
        contents:
          - text: "R"
            href: referenz/r.qmd
          - text: "Python"
            href: referenz/python.qmd
      # Bis Phase 3, danach löschen:
      - section: "Alte Struktur"
        href: cas-grundlagen/index.qmd
        contents:
          - (die bisherigen Einträge unverändert)
```

`auto:` übernimmt alle Seiten eines Ordners in die Sidebar, sortiert nach
`order` (Quarto: `sidebar` mit `auto` sortiert nach `order` im Frontmatter,
sonst nach Titel). Damit muss beim Anlegen einer Seite nichts mehr in der
Sidebar eingetragen werden; `index.qmd` und `fragen.qmd` werden über das `href`
der Section bzw. den expliziten Eintrag ausgeschlossen (Quarto zeigt `index.qmd`
nicht doppelt, wenn sie das `href` der Section ist). Falls `auto` in der
eingesetzten Quarto-Version die `order`-Sortierung nicht respektiert, werden
die Einträge explizit gelistet; das ist der einzige Ort, an dem dann Handarbeit
bleibt.

Regeln, die bleiben: Jede `section` hat ein `href`, sonst erscheint der Eintrag
doppelt. Neue Ordner müssen in `project.render` stehen. Die auskommentierten
Einträge für die Platzhaltermodule werden entfernt.

---

## 9. Build, Pakete, Rechenzeit

### 9.1 Freeze

Bisher rechnet jeder Push alle Seiten neu. Im Zielzustand sind das grob 250
ausführbare Chunks in zwei Sprachen plus Abbildungen; ein Push würde 15 bis 25
Minuten dauern, und ein einziger fehlerhafter Chunk auf irgendeiner Seite
bricht den ganzen Build ab. Deshalb:

- `execute: freeze: auto` in `_quarto.yml`. Quarto legt die Chunk-Ergebnisse in
  `_freeze/` ab und rechnet eine Seite nur neu, wenn sich ihr Quelltext
  geändert hat.
- `_freeze/` wird **ins Repo committet** (nicht in `.gitignore`), damit die
  Action die Ergebnisse vorfindet. Das ist der von Quarto vorgesehene Weg für
  CI ohne lokales Rendern. Da Quarto lokal nicht läuft, entstehen die
  Freeze-Dateien in der Action; deshalb bekommt die Action einen Schritt, der
  `_freeze/` nach dem Rendern zurück auf `main` committet (mit
  `[skip ci]` in der Commit-Message, sonst Endlosschleife).
- Alternativ, falls der Rück-Commit unerwünscht ist: `actions/cache` auf
  `_freeze/` mit einem Key aus dem Hash aller `.qmd`-Dateien. Weniger sauber,
  weil der Cache verfallen kann; erste Wahl ist der Commit.

Folge für die Arbeitsweise: Eine Seite wird nur neu gerechnet, wenn ihre
`.qmd` sich ändert. Ändert sich ein Paket in `publish.yml`, muss `_freeze/`
für die betroffenen Seiten gelöscht werden (oder ganz), sonst zeigen sie alte
Ergebnisse.

### 9.2 Pakete in `publish.yml`

Die Pakete für alle Methodenseiten werden **in Phase 1** eingetragen, nicht
seitenweise nachgereicht. Jede Nachreichung riskiert einen Build-Bruch und
einen Freeze-Reset.

R:

```
knitr rmarkdown reticulate
ggplot2 dplyr tidyr readr lubridate stringr forcats purrr tibble broom
DBI RSQLite
car lmtest sandwich          Diagnostik: VIF, Breusch-Pagan, robuste SE
survival survminer           Kaplan-Meier, Log-Rank, Cox
psych GPArotation            EFA
factoextra cluster           PCA-Plots, Clustering, Silhouette
forecast tseries             ARIMA, ADF
effectsize pwr               Effektstärken, Power
```

Python:

```
numpy pandas matplotlib seaborn scipy
statsmodels pingouin         Modelle, Tests mit CI und Effektstärke
lifelines                    Survival
scikit-learn                 PCA, Clustering, Klassifikationsgüte
factor_analyzer              EFA
plotly
```

R-Pakete werden über `r-lib/actions/setup-r-dependencies` mit einer
`DESCRIPTION`-Datei im Repo-Root installiert und gecacht, statt bei jedem Lauf
mit `install.packages()` neu. Python über `pip` mit `cache: pip` in
`setup-python` und einer `requirements.txt`. Beide Dateien sind damit die
einzige Wahrheit über die Rechenumgebung; `publish.yml` verweist nur darauf.

### 9.3 Der Build ist die einzige Probe

Quarto, R und Python laufen nicht lokal. Einfache, offensichtliche Idiome,
keine exotischen Konstruktionen. Nach jedem Push das Action-Log lesen; ein
roter Build wird sofort behoben, nicht mit dem nächsten Commit überschrieben.

---

## 10. Migration der bestehenden Inhalte

Die bisherigen Seiten sind die **Quelle** für die neuen. Nichts wird neu
erfunden, was schon geschrieben ist; die Texte werden verschoben, umbenannt,
zusammengeführt oder aufgeteilt. Danach werden sie auf Kursbezüge geprüft
(Abschnitt 2) und auf den neuen Seitentyp gebracht.

### Zuordnung alt zu neu

| Alt | Neu | Bemerkung |
|---|---|---|
| pyfr/lesson1 | programmierung/python-grundlagen | |
| pyfr/lesson2 | programmierung/python-funktionen-module | |
| pyfr/lesson3 | programmierung/python-objektorientierung | |
| pyfr/lesson4 | programmierung/python-exceptions-io | Serialisierung (JSON, Pickle) zusätzlich nach daten/datenimport-formate |
| pyfr/lesson5 | programmierung/pakete-umgebungen | mit renv aus esds/lesson1 |
| pyfr/lesson6 | programmierung/numpy-scipy | SciPy-Statistikteil verweist auf statistik/ |
| pyfr/lesson7 | programmierung/pandas | Wrangling-Teil nach daten/data-wrangling |
| pyfr/lesson8 | visualisierung/matplotlib | |
| pyfr/lesson9 | werkzeuge/linux-shell | |
| pyfr/lesson10 | werkzeuge/git | |
| pyfr/lesson11 | werkzeuge/docker-virtualisierung | |
| pyfr/lesson12 | daten/datenmodellierung + daten/sql + daten/datenbanken-zugriff | aufteilen |
| esds/lesson1 | programmierung/r-grundlagen + programmierung/reproduzierbarkeit | Quarto/Projekte nach reproduzierbarkeit |
| esds/lesson2 | daten/tidy-data + daten/data-wrangling + daten/datum-zeit + daten/datenimport-formate | aufteilen, pandas-Teil aus pyfr/lesson7 dazu |
| esds/lesson3 | statistik/grundlagen/skalenniveaus + statistik/grundlagen/haeufigkeiten | aufteilen |
| esds/lesson4 | statistik/grundlagen/lage-streuungsmasse | |
| esds/lesson5 | visualisierung/ggplot2 | |
| esds/lesson6 | statistik/grundlagen/explorative-datenanalyse | Datenqualitäts-Teil nach daten/datenqualitaet |
| esds/lesson7 | statistik/wahrscheinlichkeit/kombinatorik-wahrscheinlichkeit | |
| esds/lesson8 | statistik/wahrscheinlichkeit/bedingte-wahrscheinlichkeit-bayes | |
| esds/lesson9 | statistik/wahrscheinlichkeit/zufallsvariablen + diskrete-verteilungen | aufteilen |
| esds/lesson10 | statistik/wahrscheinlichkeit/stetige-verteilungen + normalverteilung-zgws + qq-plots | aufteilen |
| esds/lesson11 | statistik/grundlagen/korrelation + statistik/tests/korrelationstests + statistik/regression/einfache-lineare-regression | aufteilen; Test und Regression werden Methodenseiten |
| esds/lesson12 | statistik/inferenz/schaetzen-konfidenzintervalle | wird Methodenseite |
| esds/lesson13 | statistik/inferenz/hypothesentests-grundlagen + tests/t-test-eine-stichprobe + t-test-zwei-stichproben + t-test-gepaart | aufteilen; Tests werden Methodenseiten |
| esds/lesson14 | statistik/tests/chi-quadrat-tests | wird Methodenseite |
| pyfr/quiz | programmierung/fragen.qmd, daten/fragen.qmd | Fragen nach Thema verteilen |
| esds/quiz | statistik/fragen.qmd | |
| statda/lesson1 bis 5 | Gerüste, nicht migrieren | Inhalt entsteht neu nach 4.3 |
| davi/lesson1 bis 5 | Gerüste, nicht migrieren | Inhalt entsteht neu nach 4.2 und 4.4 |

### Regeln beim Migrieren

- Beim **Aufteilen** bekommt jede neue Seite ihr eigenes Vorwissen-Kästchen,
  eigene Kernideen und eigene Quizfragen; Querverweise zwischen den Teilen
  werden gesetzt.
- Beim **Zusammenführen** (pandas-Wrangling aus zwei Quellen) wird nicht
  hintereinander kopiert, sondern zu einem Text verwoben. Doppelte Erklärungen
  fallen weg.
- Wird eine bisherige Konzept-Seite zur **Methodenseite** (Regression, t-Test,
  Chi-Quadrat, Konfidenzintervalle), wird der vorhandene Text auf die neuen
  Abschnitte verteilt und die fehlenden Abschnitte (Output lesen, drei
  Szenarien, Ergebnis berichten) neu geschrieben.
- Querverweise zeigen auf die neuen Pfade. Kein Link darf mehr in einen
  `cas-*`-Ordner zeigen.
- Chunk-Labels bleiben, solange sie auf der neuen Seite eindeutig sind. Beim
  Zusammenführen kollidierende Labels umbenennen.
- Glossar (`glossary.yml`) braucht keine Änderung; die `tags` in mehrdeutigen
  Einträgen prüfen, ob sie noch zu den `categories` der neuen Seiten passen.
- `quelle` setzen: `PYFR` für Seiten aus pyfr/, `ESDS` für Seiten aus esds/,
  beide bei zusammengeführten.

---

## 11. Arbeitsauftrag an Claude Code: die drei Phasen

Die Phasen werden **nacheinander** abgearbeitet und jeweils mit einem Push
abgeschlossen, damit die GitHub Action baut und Fehler früh sichtbar werden.

### Phase 1: Infrastruktur und Struktur

Ziel: Listings, Freeze, Pakete und Filter funktionieren; die komplette neue
Navigation ist online; jede Seite existiert als Gerüst; Übersicht und
Statusseite verlinken alles automatisch. Noch kein Inhalt.

Reihenfolge ist wichtig: **zuerst die Mechanik, dann die 80 Gerüste.** Wer
zuerst 80 Seiten anlegt und dann das Listing-Template baut, fasst jede Seite
zweimal an.

1. **Build-Grundlage:** `DESCRIPTION` und `requirements.txt` mit allen Paketen
   aus 9.2 anlegen, `publish.yml` auf `setup-r-dependencies` und `pip cache`
   umstellen, `freeze: auto` setzen, Rück-Commit von `_freeze/` einbauen.
   Push, Build muss grün sein, bevor es weitergeht. Diese Änderung allein
   rechnet die bestehenden Seiten einmal neu; danach nie wieder ohne Grund.
2. **Mechanik:** `_templates/karten.ejs` und `stand.lua` schreiben.
   An **einer** Testseite prüfen, dass Karte, Badge und Platzhalterhinweis
   stimmen. Push.
3. **Gerüste:** Alle Ordner und Dateien aus Abschnitt 3 anlegen. Jede
   Themenseite enthält das vollständige Front Matter (4.1, `stand: geruest`,
   `order`, `seitentyp` nach der K/M/W-Markierung) und **alle
   Abschnittstitel ihres Seitentyps** als leere `##`-Überschriften. Die Seite
   wird gebaut und zeigt über `stand.lua` den Platzhalterhinweis; Gerüste
   enthalten keine ausführbaren Chunks und kosten im Build praktisch nichts.
4. **Bereichsseiten** mit Listing und erklärendem Absatz (7.3).
   Entscheidungsbaum in `statistik/tests/index.qmd` und die Modellwahl in
   `statistik/regression/index.qmd` bereits ausformulieren; das ist Struktur,
   nicht Inhalt. `fragen.qmd` je Bereich mit Front Matter und leerem Rumpf.
5. **Referenz:** `referenz/r.qmd` und `referenz/python.qmd` mit allen
   Abschnittstiteln und je einer leeren Tabelle. `referenz/index.qmd`.
6. **`index.qmd`** (7.2) mit Lesepfaden und Listings, **`stand.qmd`** (7.4).
7. **`_quarto.yml`** (Abschnitt 8): Titel, Footer, Navbar, neue Sidebar oben,
   alte darunter, `project.render`. `README.md` neutral umschreiben.
8. Neutralitätsprüfung (Abschnitt 2) auf alle neuen Dateien.
9. Push. Build abwarten. Übersicht, Statusseite, alle Bereichsseiten öffnen:
   keine 404, keine doppelten Sidebar-Einträge, Karten mit Badges, Gerüste
   mit Platzhalterhinweis.

### Phase 2: Inhalt

Ziel: Seite für Seite wird von `geruest` auf `entwurf` und nach Prüfung auf
`fertig` gebracht (`stand` setzen).

Reihenfolge, bewusst so gewählt:

1. **Zuerst die sechs Methodenseiten Regression und Überlebenszeit**
   (einfache und multiple lineare Regression, Regressionsdiagnostik,
   logistische Regression, Klassifikationsgüte, dann Kaplan-Meier, Log-Rank,
   Cox). Grund: Sie sind der aktuelle Stoff, die Factsheets im Ordner
   `13 StatDa - Statistische Datenanalyse/Factsheets/` und die Dateien in
   `PVA 1/` liegen als eigene Vorarbeit vor, und sie testen die
   Methodenschablone unter realen Bedingungen. Zeigt sich an der multiplen
   Regression, dass die Schablone nicht trägt, wird sie angepasst, **bevor**
   26 Seiten migriert sind. Factsheets werden umformuliert, nicht kopiert,
   und auf Kursbezüge geprüft.
2. **Migration** der Grundlagen nach der Tabelle in Abschnitt 10. Zuerst die
   Seiten, die 1:1 verschoben werden, dann die aufgeteilten, dann die
   zusammengeführten. Jede migrierte Seite: Kursbezüge entfernen, `quelle`
   setzen, Querverweise auf neue Pfade, `stand: entwurf`.
3. **Methodenseiten Tests und Inferenz**, dann Multivariat, dann Zeitreihen,
   jeweils wenn der Stoff vorliegt.
4. **Befehlsreferenz** wächst parallel: Mit jeder fertigen Themenseite werden
   ihre Befehle in `referenz/r.qmd` und `referenz/python.qmd` eingetragen.
5. **Fragen-Seiten** wachsen parallel: je fertige Themenseite zwei bis drei
   übergreifende Fragen in die `fragen.qmd` des Bereichs.
6. **Visualisierung** nach 4.2 und 4.4.

Pro Seite ein Commit. Nach jeder Handvoll Seiten ein Push und Build-Kontrolle.
Dank Freeze rechnet der Build nur die geänderten Seiten.

### Phase 3: Alte Struktur entfernen

Erst, wenn jede Zeile der Migrationstabelle abgearbeitet ist und keine Seite
mehr `stand: geruest` trägt, die aus einer alten Seite gespeist wird:

1. Prüfen, dass kein Link mehr in `cas-*` zeigt:
   `grep -rn "cas-" --include="*.qmd" --exclude-dir=docs --exclude-dir=_freeze .`
   muss leer sein (ausser in den alten Ordnern selbst).
2. Ordner `cas-grundlagen/`, `cas-statda-davi/`, `cas-ml/`, `cas-dea/`,
   `cas-ai-eng/`, `cas-adv-ml/`, `masterthesis/` löschen, dazu ihre Einträge
   in `_freeze/`.
3. Sidebar-Abschnitt "Alte Struktur" und die Einträge in `project.render`
   entfernen.
4. `instruction.md` löschen, `new_instruction.md` in `instruction.md`
   umbenennen.
5. Neutralitätsprüfung ohne Ausnahmen, Push, Build-Kontrolle.

---

## 12. Was Claude Code bei jeder Seite liefert

Pro Seite **eine vollständige `.qmd`-Datei**, fertig zum Speichern:

- Front Matter nach 4.1, Abschnitte nach dem Seitentyp, in der festgelegten
  Reihenfolge, keine weggelassen, keine zusätzlichen `##`.
- Bei Methodenseiten: vollständiger Output in beiden Sprachen, jeder Wert
  erklärt, mindestens drei Szenarien mit Output und Ergebnissatz. Python nach
  der Vorgabe in 4.3 (pingouin, statsmodels, lifelines, scikit-learn).
- Codebeispiele lauffähig und minimal, Daten im Chunk erzeugt, Seed gesetzt,
  nur Pakete aus `DESCRIPTION` und `requirements.txt`. Fehlt eines, wird es
  dort eingetragen, im Commit erwähnt und `_freeze/` für die betroffenen
  Seiten gelöscht.
- Befehle der Seite in beide Referenzseiten eingetragen; zwei bis drei Fragen
  in die `fragen.qmd` des Bereichs.
- Kein Eintrag in `_quarto.yml`, keine Karte von Hand: Listing und Sidebar
  `auto` übernehmen das über `order` im Frontmatter. Neue Unterordner müssen
  in `project.render` stehen.
- Keine erfundenen Quellen, keine erfundenen Inhalte. Was nicht belegt ist,
  wird als `.open-question` markiert.
- Alles in eigenen Worten. Slides, Skripte und Aufgabenblätter werden nicht
  abgeschrieben, auch nicht leicht umformuliert; Formeln, Definitionen und
  Fachbegriffe sind Allgemeingut.

---

## 13. Unverändert gültig aus `instruction.md`

Diese Regeln gelten weiter und werden hier nur benannt, nicht wiederholt:

- **Tabsets:** Jedes Beispiel in R und Python im `::: panel-tabset`, `## R`
  immer zuerst (die Tab-Farben hängen an der Position).
- **Chunks:** Ausführbare Chunks ```` ```{r} ```` / ```` ```{python} ```` nur,
  wenn Output oder Grafik entstehen soll; sonst Listings mit Sprachangabe.
  Jeder Chunk mit `#| label:`, Abbildungen mit `fig-`-Präfix und `#| fig-cap:`.
  Setup-Chunk mit `#| include: false`, Seed darin. Keine Vorbedingungen, keine
  Breitenangaben pro Chunk.
- **Formatierungsbausteine:** nur `.note-box`, `.open-question`,
  `.placeholder-notice`, `panel-tabset`, `.callout-note collapse="true"`,
  `.quiz`. `.lesson-card` und `.card-grid` bleiben in `styles.scss`, werden
  aber nur noch vom Listing-Template erzeugt. Kein eigenes HTML, keine
  Inline-Styles.
- **Quiz:** Format aus `quiz.lua`, jede Antwort mit Erklärung nach der Tilde,
  Fragen prüfen Interpretation.
- **Querverweise:** erstes Vorkommen verlinken, ein Link je Zielseite, nie auf
  sich selbst, nur im Fliesstext und in den Kernideen.
- **Glossar:** `glossary.yml` zentral, nichts in den Seiten eintragen.
- **`docs/`** ist generiert, nie von Hand ändern. `_freeze/` wird nur über den
  Build geschrieben, nie von Hand editiert, aber gezielt gelöscht, wenn eine
  Seite neu gerechnet werden soll.

---

## 14. Checkliste vor dem Push

- [ ] Neutralitätsprüfung (Abschnitt 2) ohne Treffer ausser `quelle:`
- [ ] Front Matter vollständig: `title`, `description`, `categories`,
      `quelle`, `seitentyp`, `stand`, `order`
- [ ] 3 bis 6 Tags aus dem Vokabular, keine Kurscodes, `Interpretation` auf
      Methodenseiten
- [ ] Seitentyp entspricht der K/M/W-Markierung in Abschnitt 3
- [ ] Abschnitte des Seitentyps vollständig und in der richtigen Reihenfolge
- [ ] Methodenseite: jeder Output-Wert erklärt, mindestens drei Szenarien mit
      Output und Ergebnissatz, Vorlage für den Berichtssatz vorhanden, Python
      mit pingouin/statsmodels statt nacktem scipy
- [ ] In jedem Tabset R zuerst; jedes Beispiel in beiden Sprachen
- [ ] Chunks laufen ohne Vorbedingung, Seed gesetzt, Labels eindeutig
- [ ] Nur Pakete aus `DESCRIPTION` und `requirements.txt`
- [ ] Befehle der Seite in `referenz/r.qmd` und `referenz/python.qmd`
- [ ] Zwei bis drei Fragen in der `fragen.qmd` des Bereichs
- [ ] Neuer Unterordner in `project.render`; sonst kein Eintrag in
      `_quarto.yml` nötig
- [ ] Kein Link in einen `cas-*`-Ordner
- [ ] Nichts wörtlich aus Kursunterlagen, keine erfundenen Links
- [ ] Keine Gedankenstriche im Fliesstext
- [ ] Nichts in `docs/` oder `_freeze/` von Hand geändert
- [ ] Action-Log nach dem Push gelesen, Build grün
