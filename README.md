# Data Science Notizen

Persönliche Lern- und Nachschlageseite zu Data Science, gebaut mit Quarto.
Öffentliches Repo, aber nicht gelistet und nicht indexiert, erreichbar nur für
alle, die den Link kennen.

## Struktur

Die Seite ist nach Themen gegliedert, nicht nach Kursen. Jede Datei ist ein
Thema, jeder Ordner ein Bereich.

```
index.qmd                 Übersicht mit Lesepfaden, Karten aus dem Frontmatter
stand.qmd                 Statusübersicht aller Seiten
programmierung/           Python, R, Pakete, Umgebungen, Reproduzierbarkeit
daten/                    Import, Tidy Data, Wrangling, Qualität, SQL
werkzeuge/                Shell, Git, Container
statistik/                Grundlagen, Wahrscheinlichkeit, Inferenz, Tests,
                          Regression, Überlebenszeit, Multivariat, Zeitreihen
ki/                       Prompts, Patterns, Grenzen von Sprachmodellen
visualisierung/           Wahrnehmung, Diagrammwahl, ggplot2, matplotlib, mehr
referenz/                 Befehlsreferenz R und Python
_templates/karten.ejs     Vorlage, aus der die Karten der Übersichten entstehen
_freeze/                  gerechnete Chunk-Ergebnisse, gehört ins Repo
```

Jedes Beispiel steht in R und Python nebeneinander (`panel-tabset`), R zuerst.

## Seitentypen

| Typ | Wofür | Aufbau |
|---|---|---|
| Konzept | erklärt einen Begriff | Kernideen, Erklärung, Ressourcen |
| Methode | führt ein Verfahren durch | Steckbrief, Voraussetzungen, Durchführung, Output lesen, Szenarien, Fallen, Berichten |
| Werkzeug | zeigt die Handhabung | Kernideen, Erklärung, typische Aufgaben |
| Referenz | listet Befehle | Tabellen je Themenabschnitt |

Der Typ steht im Frontmatter (`seitentyp`), ebenso der Bearbeitungsstand
(`stand`), die Reihenfolge im Bereich (`order`) und die Herkunft des Stoffs
(`quelle`). Aus diesen Feldern entstehen Karten, Sidebar-Reihenfolge und
Statusübersicht automatisch; von Hand wird dafür nichts gepflegt.

## Rechenumgebung und Build

Die Seiten enthalten ausführbare Chunks: Abbildungen und Zahlen entstehen beim
Build aus dem Code, der auf der Seite steht. R und Python samt Paketen richtet
die GitHub Action ein, siehe `.github/workflows/publish.yml`. Wird ein neues
Paket gebraucht, muss es zuerst dort eingetragen werden, sonst bricht der Build
ab.

`execute: freeze: auto` sorgt dafür, dass nur geänderte Seiten neu gerechnet
werden. Die Ergebnisse liegen in `_freeze/` und werden von der Action nach jedem
Lauf ins Repo zurückgeschrieben. Soll eine Seite erzwungenermassen neu rechnen,
etwa nach einem Paket-Update, wird ihr Ordner unter `_freeze/` gelöscht.

`docs/` ist generiert und wird nie von Hand geändert.

## Lokal testen (optional)

Voraussetzung: [Quarto CLI](https://quarto.org/docs/get-started/).

```bash
quarto preview
```

## Hinweise

- `robots.txt` blockiert Crawler, jede Seite trägt zusätzlich ein `noindex`.
- Alles im Repo ist technisch öffentlich einsehbar, sobald jemand die URL kennt.
  Deshalb enthält die Seite ausschliesslich eigene Notizen und keine
  Materialien Dritter.
