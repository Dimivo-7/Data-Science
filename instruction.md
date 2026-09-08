# Anleitung: Kursunterlagen für diese Notizseite aufbereiten

Diese Datei beschreibt, in welcher Form Inhalte vorliegen müssen, damit sie ohne
Nacharbeit in die Website übernommen werden können. Sie richtet sich an mich
selbst **und** an eine KI, die aus Slides, Skripten oder Mitschriften fertige
`.qmd`-Seiten erzeugen soll.

Abschnitt 9 enthält einen fertigen Prompt zum Kopieren.

---

## 1. Was das hier technisch ist

| | |
|---|---|
| Generator | [Quarto](https://quarto.org) (Website-Projekt) |
| Quellformat | `.qmd` — Markdown mit YAML-Front-Matter |
| Theme | Bootstrap 5, `cosmo` (hell) / `darkly` (dunkel), plus `styles.scss` |
| Hosting | GitHub Pages, Branch `gh-pages` |
| Build | GitHub Actions (`.github/workflows/publish.yml`) bei jedem Push auf `main` |
| Rechenumgebung | Die Action richtet R und Python samt Paketen ein und führt die Chunks aus |

**Wichtig:** Quarto ist auf meinem Rechner nicht installiert. Ich schreibe nur
`.qmd`-Dateien und pushe sie; das Rendern übernimmt die GitHub Action. Der
Ordner `docs/` ist generiert und liegt in `.gitignore` — dort **niemals** von
Hand etwas ändern.

---

## 2. Verzeichnisstruktur

```
mas-data-science-notizen/
├── index.qmd                       Startseite mit Modulkarten
├── tags.qmd                        Tag-Übersicht (automatisch befüllt)
├── instruction.md                  diese Datei
├── _quarto.yml                     Navigation, Rendern, Theme
├── styles.scss                     gesamtes Design
├── lastupdate.lua                  setzt den Zeitstempel oben auf jeder Seite
├── cas-grundlagen/
│   ├── index.qmd                   Modulübersicht
│   ├── pyfr/
│   │   ├── index.qmd               Teilbereichsübersicht
│   │   └── lesson1.qmd … lesson12.qmd
│   └── esds/
│       ├── index.qmd
│       └── lesson1.qmd … lesson14.qmd
└── cas-statda-davi/
    ├── index.qmd                   Modulübersicht
    ├── statda/
    │   ├── index.qmd               Teilbereichsübersicht
    │   └── lesson1.qmd … lesson5.qmd
    └── davi/
        ├── index.qmd
        └── lesson1.qmd … lesson5.qmd
```

**Namensregeln**

- Ordner und Dateien: klein, ohne Umlaute, ohne Leerzeichen (`cas-statda-davi`)
- Lektionen fortlaufend: `lesson1.qmd`, `lesson2.qmd`, …
- Jede Übersichtsseite heißt `index.qmd`
- Kodierung UTF-8, Zeilenenden LF

---

## 3. Front Matter — Pflichtfelder

Jede Lektionsseite beginnt exakt so:

```yaml
---
title: "L3 – PCA & EFA"
description: "Hauptkomponentenanalyse und explorative Faktorenanalyse inklusive Rotationsmethoden."
categories: ["Dimensionsreduktion", "Faktorenanalyse", "R", "Python"]
---
```

| Feld | Regel |
|---|---|
| `title` | `L<Nr> – <Thema>`. Gedankenstrich `–` (en dash), keine Klammern, max. ~45 Zeichen. Der Titel erscheint in der Sidebar — zu lange Titel brechen dort um. |
| `description` | **Ein** vollständiger Satz, max. ~120 Zeichen. Erscheint in der Tag-Übersicht. Beschreibt den Inhalt, nicht die Lernziele. |
| `categories` | Die Tags. Regeln siehe Abschnitt 5. |

Übersichtsseiten (`index.qmd`) bekommen zusätzlich `comments: false` und **keine**
`categories`.

---

## 4. Aufbau einer Lektionsseite

Alle Lektionsseiten haben **dieselben vier Abschnitte in dieser Reihenfolge**.
Keine weggelassenen, keine zusätzlichen `##`-Abschnitte — die Einheitlichkeit
ist der Punkt der ganzen Seite. Innerhalb von „Meine Zusammenfassung" sind
`###`-Zwischentitel erwünscht; sie erscheinen im Inhaltsverzeichnis rechts und
machen lange Seiten navigierbar.

````markdown
---
title: "L3 – PCA & EFA"
description: "…"
categories: ["…"]
---

## Kernideen aus dem Kurs

- 4 bis 6 Stichpunkte
- jeweils ein Begriff oder Konzept, keine ganzen Sätze
- das ist das Inhaltsverzeichnis der Lektion

## Meine Zusammenfassung

Das Herzstück der Seite: ein ausführlicher Erklärtext in eigenen Worten,
gegliedert mit `###`-Zwischentiteln. Hierhin gehören Formeln, gerechnete
Beispiele und Abbildungen direkt im Fluss — die Seite soll als Nachschlagewerk
tragen und mit der Zeit wachsen.

### Ein Zwischentitel je Gedanke

Fliesstext, dazu ein gerechnetes Beispiel:

```{r}
#| label: robustheit
x <- c(12, 14, 15, 15, 18, 21)
c(mittel = mean(x), median = median(x))
```

Und eine Abbildung mit Beschriftung:

```{r}
#| label: fig-verteilung
#| fig-cap: "Was die Abbildung zeigt, in einem Satz."
ggplot(data.frame(x), aes(x)) + geom_histogram(bins = 20)
```

## Eigene Beispiele / Code

Die kompakte R/Python-Gegenüberstellung zum Nachschlagen. Bleibt auch dann
bestehen, wenn im Text schon Code steht — dort wird erklärt, hier verglichen.

::: panel-tabset
## R

```r
prcomp(df, scale. = TRUE)
```

## Python

```python
from sklearn.decomposition import PCA
PCA(n_components=2).fit(X)
```
:::

## Verlinkte Ressourcen

- [Original-Kursseite](https://…) *(zum Nachschlagen)*
````

### Ausführbare Chunks und reine Listings

Es gibt zwei Sorten Codeblöcke, und die Unterscheidung ist wichtig:

| Schreibweise | Verhalten | wofür |
|---|---|---|
| ```` ```{r} ```` bzw. ```` ```{python} ```` | wird beim Build **ausgeführt**, Ausgabe und Grafik landen auf der Seite | Abbildungen, gerechnete Beispiele im Erklärtext |
| ```` ```r ```` bzw. ```` ```python ```` | wird nur **angezeigt** | Listings im Tabset, Fragmente, Shell-Befehle |

Für ausführbare Chunks gilt:

- **Sie müssen ohne Vorbedingung laufen.** Ein Chunk, der ein `df` erwartet,
  das es nicht gibt, bricht den ganzen Build ab. Daten im Chunk selbst
  erzeugen (`rnorm`, `data.frame`) oder einen eingebauten Datensatz nehmen.
- **`set.seed()` in den Setup-Chunk**, sonst ändern sich Zahlen und Grafiken
  bei jedem Build und die Seite erzählt jedes Mal etwas anderes.
- **Jeder Chunk bekommt ein `#| label:`**, Abbildungen zusätzlich
  `#| fig-cap:`. Labels von Abbildungen beginnen mit `fig-`.
- Der Setup-Chunk oben auf der Seite trägt `#| include: false` und lädt die
  Pakete.
- Verwendet werden dürfen nur Pakete, die in
  `.github/workflows/publish.yml` installiert sind. Neues Paket gebraucht?
  Erst dort eintragen.

**Der Build ist die einzige Probe.** Quarto, R und Python laufen nicht auf
meinem Rechner — ein Fehler im Chunk zeigt sich erst in der GitHub Action.
Deshalb: einfache, offensichtliche Idiome, keine exotischen Konstruktionen.

### Zwingend: R vor Python

Im `panel-tabset` steht **immer `## R` zuerst, `## Python` als zweites.**

Das ist keine Stilfrage. Die Tab-Einfärbung in `styles.scss` erkennt die Sprache
an der Position (`:nth-child(1)` = R-Blau `#276DC3`, `:nth-child(2)` =
Python-Blau), weil Quarto den Tab-Buttons keine Sprachinformation mitgibt. Wird
die Reihenfolge in einer Datei gedreht, sind dort die Farben vertauscht.

Gibt es nur eine Sprache, trotzdem beide Tabs anlegen und im leeren notieren,
warum er leer ist.

---

## 5. Tags

### Prinzip

Tags beantworten: **„Wo habe ich das schon mal gehabt?"** Sie sind ein
Suchwerkzeug über Modulgrenzen hinweg, keine Zusammenfassung. Deshalb:

- **3 bis 5 Tags pro Seite.** Weniger trägt nicht, mehr verwässert.
- **Nur aus dem Vokabular unten.** Ein Tag, den es nur einmal gibt, ist nutzlos —
  er findet nichts, was man nicht schon gefunden hat.
- **Kein Tag, der das Modul wiederholt.** `STATDA` oder `CAS` sind keine Tags,
  das steht schon in der Navigation.
- Schreibweise exakt übernehmen, inklusive Groß-/Kleinschreibung. `Python` und
  `python` wären zwei verschiedene Tags.

### Aktuelles Vokabular

| Gruppe | Tags |
|---|---|
| Sprache | `R`, `Python` |
| Bibliotheken | `ggplot2`, `tidyverse`, `matplotlib`, `seaborn`, `plotly`, `pandas`, `NumPy` |
| Programmierung | `Programmiergrundlagen`, `Tooling`, `Reproduzierbarkeit` |
| Daten & Infrastruktur | `SQL`, `Datenbanken`, `Linux` |
| Beschreibende Statistik | `Deskriptive Statistik`, `EDA`, `Korrelation` |
| Wahrscheinlichkeit | `Wahrscheinlichkeit`, `Verteilungen`, `Bayes` |
| Statistische Verfahren | `Schätzen`, `Regression`, `Hypothesentests`, `Versuchsplanung`, `A/B-Testing`, `Dimensionsreduktion`, `Faktorenanalyse`, `Clustering`, `Distanzmasse`, `Zeitreihen`, `Prognose`, `Survival-Analyse` |
| Modellgüte | `Modelldiagnostik`, `Modellvalidierung` |
| Visualisierung | `Visualisierung`, `Wahrnehmung`, `Farbe`, `Dashboards`, `Interaktivität`, `Storytelling`, `Kommunikation`, `Visualisierungsethik` |
| Betrieb | `Deployment` |

### Neuen Tag einführen

Erlaubt, wenn das Thema **auf mindestens zwei Seiten** vorkommt oder absehbar
vorkommen wird. Dann:

1. Tag in die Tabelle oben eintragen (diese Datei ist die Referenzliste),
2. auf allen betroffenen Seiten ergänzen.

Ein Tag, der dauerhaft allein bleibt, gehört gelöscht.

### Wo Tags erscheinen

- Als Pills unter dem Titel jeder Seite
- Auf `tags.qmd` als Wolke zum Filtern und an jedem Eintrag als Chip
- Beides entsteht automatisch aus `categories:`. Es gibt **keine** Liste, die
  zusätzlich gepflegt werden müsste.

---

## 6. Formatierungsbausteine

Nur diese verwenden — sie sind in `styles.scss` gestaltet und funktionieren in
hell und dunkel:

| Baustein | Wofür |
|---|---|
| `::: {.note-box}` | Hinweis, Merksatz, Einordnung |
| `::: {.open-question}` | Offene Frage, Unklarheit (gelb markiert) — kein fester Abschnitt mehr, nur noch dort, wo eine Frage wirklich offen ist |
| `::: {.placeholder-notice}` | Platzhalter: Inhalt existiert noch nicht |
| `::: {.lesson-card}` in `:::: {.card-grid}` | Kartenraster auf Übersichtsseiten |
| `::: panel-tabset` | R/Python nebeneinander |

**Karten immer im Raster.** Eine `.lesson-card` ohne umschließendes
`.card-grid` läuft über die volle Breite und sieht anders aus als überall sonst.
Das äußere Div braucht mehr Doppelpunkte als das innere:

```markdown
:::: {.card-grid}

::: {.lesson-card}
### [Titel](ziel.qmd)

Ein Satz Beschreibung.
:::

::::
```

### Querverweise zwischen Seiten

Taucht ein Fachbegriff auf, für den es eine eigene Lektionsseite gibt, wird er
verlinkt — wie in einem Wiki. Ein normaler Markdown-Link auf die `.qmd`-Datei,
Quarto macht daraus beim Rendern den richtigen Pfad:

```markdown
Die Standardabweichung hat gegenüber der [Varianz](lesson4.qmd) den Vorteil …
Der Vergleich zu [Matplotlib](../pyfr/lesson8.qmd) fällt deutlich aus …
```

Damit die Seiten lesbar bleiben, gelten vier Regeln:

- **Nur das erste Vorkommen** eines Begriffs pro Seite verlinken, nicht jedes.
- **Höchstens ein Link je Zielseite** und Seite.
- **Nie auf die eigene Seite** verlinken — auf der Seite über die Varianz wird
  das Wort Varianz nicht verlinkt.
- **Nur im Fliesstext und in den Kernideen.** Nicht in Überschriften, nicht in
  Codeblöcken, nicht in Inline-Code.

Vorsicht bei mehrdeutigen Wörtern: „Klassen" sind in ESDS die Klassen eines
Histogramms und in PYFR Python-Klassen, „Container" meint einmal Liste und
Dictionary, einmal Docker. Solche Begriffe nur verlinken, wenn die Bedeutung
im Satz eindeutig ist.

**Codeblöcke** immer mit Sprachangabe (```` ```r ````, ```` ```python ````) —
davon hängen Syntaxhervorhebung und die farbige Kante links ab.

Nicht verwenden: eigene HTML-`<div>`s mit Inline-Styles, eigene Farbangaben,
zusätzliche CSS-Klassen. Alles Gestalterische gehört in `styles.scss`.

---

## 7. Umgang mit den Original-Kursunterlagen

Das hier ist eine private Lernseite, aber sie liegt öffentlich auf GitHub Pages.
Deshalb gilt:

- **Slides, Skripte und Aufgabenblätter nicht abschreiben.** Nicht als Zitat,
  nicht leicht umformuliert, nicht als Screenshot.
- Erlaubt und erwünscht: **eigene Zusammenfassung in eigenen Worten**, eigener
  Beispielcode, eigene Grafiken.
- Auf Originale wird **verlinkt**, unter „Verlinkte Ressourcen".
- Formeln, Definitionen und Fachbegriffe sind Allgemeingut und dürfen
  selbstverständlich verwendet werden.

Wenn eine KI die Aufbereitung macht, ist das die wichtigste Anweisung an sie:
**umformulieren, nicht übernehmen.**

---

## 8. Was die KI liefern soll

Pro Lektion **eine vollständige `.qmd`-Datei**, fertig zum Speichern:

- vollständiges Front Matter nach Abschnitt 3
- die sechs Abschnitte aus Abschnitt 4, in dieser Reihenfolge
- Codebeispiele lauffähig und minimal — die Idee zeigen, kein Komplettskript
- keine erfundenen Quellenangaben; ist die Original-URL unbekannt, dann
  stattdessen ein `.placeholder-notice` mit Hinweis darauf
- keine erfundenen Inhalte: was nicht in den Unterlagen steht, wird nicht
  ergänzt. Lücken werden als offene Frage markiert, nicht gefüllt.

---

## 9. Prompt zum Kopieren

```text
Du bereitest meine Kursunterlagen für eine Quarto-Website auf.

KONTEXT
Modul: <z. B. CAS Statistische Datenanalyse, Teilbereich STATDA>
Lektion: <Nummer und Thema>
Meine Unterlagen hänge ich an / füge ich unten ein.

AUFGABE
Erzeuge genau eine vollständige .qmd-Datei, fertig zum Speichern.

FRONT MATTER
---
title: "L<Nr> – <Thema>"          (Gedankenstrich –, max. ~45 Zeichen)
description: "<ein Satz, max. ~120 Zeichen, beschreibt den Inhalt>"
categories: [<3 bis 5 Tags>]
---

TAGS
Verwende ausschliesslich Tags aus dieser Liste, Schreibweise exakt:
R, Python, ggplot2, tidyverse, matplotlib, seaborn, plotly, pandas,
NumPy, Programmiergrundlagen, Tooling, Reproduzierbarkeit, SQL,
Datenbanken, Linux, Deskriptive Statistik, EDA, Korrelation,
Wahrscheinlichkeit, Verteilungen, Bayes, Schätzen, Regression,
Hypothesentests, Versuchsplanung, A/B-Testing, Dimensionsreduktion,
Faktorenanalyse, Clustering, Distanzmasse, Zeitreihen, Prognose,
Survival-Analyse, Modelldiagnostik, Modellvalidierung, Visualisierung,
Wahrnehmung, Farbe, Dashboards, Interaktivität, Storytelling,
Kommunikation, Visualisierungsethik, Deployment
Passt nichts, schlage am Ende einen neuen Tag vor und begründe ihn –
setze ihn aber nicht selbst ein.

AUFBAU – genau diese vier Abschnitte, genau in dieser Reihenfolge:
## Kernideen aus dem Kurs      4-6 Stichpunkte, Begriffe statt Sätze
## Meine Zusammenfassung       ausführlicher Erklärtext, mit ###-Zwischentiteln
                               gegliedert, Formeln, gerechnete Beispiele und
                               Abbildungen direkt im Text
## Eigene Beispiele / Code     ::: panel-tabset mit ## R zuerst, dann ## Python
## Verlinkte Ressourcen        Links, sonst ::: {.placeholder-notice}

AUSFÜHRBARE CHUNKS
Abbildungen und gerechnete Beispiele als ```{r} bzw. ```{python} – sie laufen
beim Build. Jeder Chunk muss ohne Vorbedingung laufen: Daten im Chunk selbst
erzeugen, nie ein df voraussetzen. Jeder Chunk mit #| label:, Abbildungen
zusätzlich mit #| fig-cap: und dem Präfix fig- im Label. set.seed() in einen
Setup-Chunk mit #| include: false. Nur Pakete aus publish.yml verwenden.
Die Listings im Tabset bleiben reine Anzeige (```r bzw. ```python).

HARTE REGELN
- Im panel-tabset steht IMMER R zuerst, Python als zweites.
- Codeblöcke immer mit Sprachangabe (```r bzw. ```python).
- Nur diese Divs: .note-box, .open-question, .placeholder-notice.
  Kein eigenes HTML, keine Inline-Styles, keine Farben.
- Formuliere alles in eigenen Worten um. Übernimm keine Formulierungen
  aus den Unterlagen, auch nicht leicht abgewandelt.
- Erfinde nichts. Was in den Unterlagen fehlt, wird nicht ergänzt; wo eine
  Frage offen bleibt, ein ::: {.open-question} setzen. Keine erfundenen URLs.
- Sprache: Deutsch. Fachbegriffe dürfen englisch bleiben.

AUSGABE
Nur der Dateiinhalt, keine Erklärung davor oder danach.
Dazu am Schluss eine Zeile: der vorgeschlagene Dateiname.
```

---

## 10. Neue Datei einbauen

1. Datei am richtigen Ort speichern (Abschnitt 2).
2. In `_quarto.yml` unter `website.sidebar.contents` eintragen.
   **Abschnitte brauchen ein eigenes `href`**, sonst erscheint der Eintrag
   doppelt — einmal als Aufklapper ohne Funktion, einmal als Seite:
   ```yaml
   - section: "STATDA"
     href: cas-statda-davi/statda/index.qmd
     contents:
       - cas-statda-davi/statda/lesson1.qmd
   ```
3. Ist das ein **neues Modul**, zusätzlich in `_quarto.yml` unter
   `project.render` eintragen — sonst wird es nicht gebaut und taucht auch in
   der Suche nicht auf. Für die derzeit ausgeblendeten Module stehen die
   passenden Zeilen dort auskommentiert bereit.
4. Bei neuem Modul: Karte in `index.qmd` ergänzen.
5. Committen und pushen. Die GitHub Action rendert und veröffentlicht.

---

## 11. Checkliste vor dem Push

- [ ] Front Matter vollständig: `title`, `description`, `categories`
- [ ] 3–5 Tags, alle aus dem Vokabular in Abschnitt 5
- [ ] Die vier Abschnitte vollständig und in der richtigen Reihenfolge
- [ ] Im Tabset: R zuerst, Python zweitens
- [ ] Alle Codeblöcke mit Sprachangabe
- [ ] Ausführbare Chunks laufen ohne Vorbedingung, mit Label und `fig-cap`
- [ ] Nur Pakete verwendet, die in `publish.yml` installiert werden
- [ ] Karten liegen in einem `.card-grid`
- [ ] Nichts wörtlich aus den Kursunterlagen übernommen
- [ ] Keine erfundenen Links
- [ ] Fachbegriffe mit eigener Seite verlinkt (erstes Vorkommen, nicht auf sich selbst)
- [ ] Seite in `_quarto.yml` eingetragen (Sidebar, ggf. `project.render`)
- [ ] Nichts in `docs/` von Hand geändert

---

## 12. Häufige Fehler

| Fehler | Folge |
|---|---|
| `.lesson-card` ohne `.card-grid` | Karte über volle Breite, Seite sieht anders aus als der Rest |
| Python-Tab vor R-Tab | Tab-Farben vertauscht |
| Codeblock ohne Sprachangabe | keine Syntaxfarben, keine farbige Kante |
| Tag mit abweichender Schreibweise | zweiter Tag im System, Filter findet nicht alles |
| `section:` ohne `href` | Menüeintrag erscheint doppelt |
| Neues Modul nicht in `project.render` | Seite wird nicht gebaut, 404 im Menü |
| Änderung direkt in `docs/` | beim nächsten Build überschrieben |
| Chunk setzt ein `df` voraus, das es nicht gibt | Build bricht ab, ganze Seite fehlt |
| Paket im Chunk, das nicht in `publish.yml` steht | Build bricht ab |
| `set.seed()` vergessen | Zahlen und Grafiken ändern sich bei jedem Build |
| Ausführbarer Chunk im Tabset statt Listing | Tabset wird unnötig langsam und fehleranfällig |
