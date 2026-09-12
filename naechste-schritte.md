# Stand und nächste Schritte

Diese Datei hält fest, wo die Arbeit steht und wie es weitergeht. Sie liegt im
Repo, damit der Stand auf jedem Rechner verfügbar ist und nicht in einem
lokalen Gedächtnis hängt.

Stand: 11. September 2026. **Alle Bereiche sind inhaltlich vollständig und auf
die Beispiel-Reiter umgestellt.** Die beiden Lücken aus dem Modulplan-Abgleich
(Prüfverteilungen, lineare Algebra für die PCA) sind geschlossen.

---

## Die Schablone für Methodenseiten

Seit dem 10.09.2026 sind Methodenseiten so aufgebaut:

```
Frontmatter, Setup-Chunks (include: false), Einleitungssatz zu den Daten

## Kurzsteckbrief          ## Interpretationsfallen
## Wann diese Methode      ## Ergebnis berichten
## Grundidee und Modell    ## Abgrenzung zu verwandten Methoden
## Voraussetzungen
## Output lesen

## Beispiele
:::: {.panel-tabset}
### Beispiel 1: <sprechender Titel>
#### Frage und Datenlage
#### Voraussetzungen prüfen       <- mit ::: {.panel-tabset} und ##### R / ##### Python
#### Rechnung                     <- ebenso
#### Output Zeile für Zeile       <- Tabelle: jeder Wert einzeln erklärt
#### Interpretation und Ergebnissatz   <- endet mit einem Zitatblock
### Beispiel 2 …
::::

## Verständnisfragen
## Verlinkte Ressourcen
```

Der Theorieteil steht **ausserhalb** des Tabsets, sonst fehlt er im
Inhaltsverzeichnis. Das äussere Tabset öffnet mit `::::`, innere mit `:::`.

Drei bis vier Beispiele je Seite, und zwar nach diesem Muster: ein Standardfall,
ein Nullbefund, ein Fallstrick (verletzte Voraussetzung), und ein Fall, der
Signifikanz von Relevanz trennt oder auf eine Nachbarseite überleitet.

## Beispieldaten

**Nie mit Zufallszahlen.** `set.seed()` in R und `default_rng()` in Python
erzeugen verschiedene Folgen; R und Python zeigen dann auf derselben Seite
verschiedene Ergebnisse, und keine Zahl im Fliesstext stimmt.

Zwei Wege:

1. Kleine Datensätze als Vektor fest eintragen.
2. Grössere deterministisch konstruieren, in R
   `qnorm(((lauf * faktor) %% n + 0.5) / n)` und in Python dasselbe mit
   `scipy.stats.norm.ppf`. Für gleichverteilte Werte den Bruch direkt nehmen.

**Achtung bei mehreren solchen Vektoren:** Sie sind nicht automatisch
unkorreliert. Vor der Verwendung die Korrelationsmatrix prüfen und Faktoren
wählen, die paarweise unter etwa 0.1 liegen. Für n = 120 hat sich die Menge
`1, 29, 53, 73, 97` bewährt.

## Ablauf vor und nach jedem Push

**Nicht pushen, solange ein Build laeuft.** Sonst geht der Freeze-Commit der
Action verloren, und `zeige-ausgaben.py` zeigt danach die Zahlen der vorherigen
Fassung, ohne es zu sagen. Siehe `build-fehler.md`.

```bash
# vorher
python pruefe-chunks.py            # lädt jede Seite, was sie benutzt?
grep -rniE "ffhs|\bmas\b|\bcas\b|…" --include="*.qmd" …   # Neutralität, siehe instruction.md Abschnitt 2

# nachher, wenn der Build grün ist
python zeige-ausgaben.py _freeze/<pfad>/execute-results/html.json
```

Der letzte Schritt ist nicht optional. Ein grüner Build sagt nur, dass der Code
lief, nicht dass der Text stimmt. Testbezeichnungen, p-Werte, Warnungen und
Konfidenzniveaus werden **abgelesen**, nicht vorhergesagt; die Gründe stehen in
`build-fehler.md`.

Statistische Kennzahlen, die sich aus den Daten ergeben (Mittelwerte, t, F,
Konfidenzintervalle), lassen sich vorab in Python nachrechnen. Ein Wegwerf-venv
mit `numpy scipy statsmodels scikit-learn pingouin` genügt dafür.

---

## Fertig

| Bereich | Seiten |
|---|---|
| `statistik/` | `verfahren-waehlen.qmd` (neu, vier Entscheidungsbäume als Mermaid) |
| `statistik/tests/` | **vollständig**: t-Test eine Stichprobe, zwei Stichproben, gepaart, ANOVA, Chi-Quadrat, nichtparametrische Tests, Korrelationstests, Normalitätstests |
| `statistik/regression/` | **vollständig**: einfache und multiple lineare Regression, logistische Regression, Regressionsdiagnostik, Modellauswahl, Klassifikationsgüte |
| `statistik/inferenz/` | **vollständig**: Schätzen und Konfidenzintervalle, Hypothesentest-Grundlagen, Effektstärken, Power, multiples Testen, Bootstrap |
| `statistik/multivariat/` | **vollständig**: Hauptkomponentenanalyse, Faktorenanalyse, Distanzmasse, k-Means, hierarchisches Clustering, Clustergüte |
| `statistik/ueberlebenszeit/` | **vollständig**: Kaplan-Meier, Log-Rank-Test, Cox-Modell, Zensierung und Überlebensfunktion |
| `statistik/zeitreihen/` | **vollständig**: Grundlagen, Stationarität und ACF/PACF, Glättung, ARIMA/SARIMA |
| `statistik/grundlagen/` | **vollständig**: Lage- und Streuungsmasse, Korrelation, Skalenniveaus, Häufigkeiten, explorative Datenanalyse |
| `statistik/wahrscheinlichkeit/` | **vollständig**: Kombinatorik, bedingte Wahrscheinlichkeit und Bayes, Zufallsvariablen, diskrete und stetige Verteilungen, Normalverteilung und ZGWS, QQ-Plots, **Prüfverteilungen** (neu) |
| `statistik/multivariat/` | zusätzlich **lineare Algebra für die PCA** (neu) |
| `referenz/` | **vollständig**: R und Python mit je 135 Befehlen in 16 Abschnitten, zeilenweise parallel aufgebaut |

## Als Nächstes

### Stand

| Bereich | Stand |
|---|---|
| `statistik/` (50 Seiten) | **fertig**, Zahlen maschinell geprüft |
| `referenz/` (2 Seiten) | **fertig**, je 135 Befehle zeilenweise parallel |
| `visualisierung/` (11 Seiten) | **fertig**, Zahlen maschinell geprüft |
| `programmierung/` (9 Seiten + Fragen) | **fertig** (12.09.2026), Zahlen maschinell und von Hand geprüft |
| `daten/` (5 Seiten + Fragen) | **umgebaut** (12.09.2026), Ausgaben gegen den Text geprüft, noch `stand: entwurf` |
| `datenbanken/` (8 Seiten) | **umgebaut** (12.09.2026): vier Seiten mit echten Beispielen gegen SQLite, vier ohne Server nur strukturell angeglichen |
| `werkzeuge/` (3 Seiten), `ki/` | unverändert, keine Beispiele |

### Erledigt am 12.09.2026

- **pandas ist in `publish.yml` auf 2.3.3 festgeschrieben.** Grund und
  Vorgehen beim Anheben stehen als Kommentar daneben.
- **Gedankenstriche entfernt**, 829 Stellen auf 49 Seiten, nicht nur in
  `visualisierung/`, sondern im ganzen Statistikbereich. Regeln: Einschub wird
  Komma, vor und/oder fällt der Strich weg, vor aber/sondern wird er zum
  Komma, Zahlbereiche werden "bis", eine Tabellenzelle mit nur einem Strich
  bleibt leer. Nach dem Neurechnen aller 49 Seiten meldet `pruefe-zahlen.py`
  keinen Befund; im HTML bleiben nur die Striche, die Quarto selbst im
  `<title>` setzt.
- **`daten/` umgebaut**: Datenimport, Tidy Data, Data Wrangling, Datum und
  Zeit, Datenqualität. Data Wrangling und Datenqualität zogen zuvor getrennte
  Zufallszahlen; jetzt feste Werte beziehungsweise ein Lehmer-Strom.

| Seite | Befund |
|---|---|
| Datenimport | aus `0815` wird 815; `read_csv2` liest `1.234` als 1234, pandas lässt die Spalte Text; `thousands` mit `Int64` gibt einen `TypeError`; Latin-1 verdirbt auch die Spaltennamen |
| Tidy Data | der Tippfehler `GH` fällt über `nunique` je Standort auf; `pivot` bricht bei doppeltem Schlüssel ab, tidyr liefert eine Listenspalte |
| Data Wrangling | ohne `.groups = "drop"` liefert das zweite `summarise` zwei Zeilen statt einer; `case_when` und `cut` teilen den Randwert 10 verschieden zu |
| Datum und Zeit | Monat als Text wirft Januar 2025 und 2026 zusammen; 31. Januar plus ein Monat ist in R ohne `%m+%` ein `NA`; zwischen 00:30 und 03:30 Ortszeit liegen in der Umstellungsnacht zwei Stunden; der 1.1.2027 liegt in ISO-Woche 53 von 2026 |
| Datenqualität | 28 fehlende Blutdruckwerte, ausschliesslich bei über 65-Jährigen (dort 50 Prozent); fünf Schreibweisen für drei Standorte; 46.5 statt 20 Prozent der Werte enden auf 0 oder 5 |

### Der Programmierbereich ist umgebaut

Alle neun Werkzeugseiten haben jetzt die Beispiel-Reiter, jede mit R- und
Python-Tab auf denselben festen Daten. Die alten Seiten zogen auf fünf Seiten
Zufallszahlen getrennt in R und Python; das ist beseitigt. Tragende Befunde:

| Seite | Befund |
|---|---|
| Python-Grundlagen | `b = a` teilt die Liste, R kopiert; `werte[-1]` bedeutet in R das Gegenteil |
| Funktionen und Module | R ergänzt `ein=` zu `einheit=`; der zweite Import bleibt stumm; `__name__` ist im Dokument `__main__` (die alte Fassung behauptete das Gegenteil) |
| Objektorientierung | Dataclass mit `order=True` sortiert 1.5 cm vor 3.0 mm |
| Fehlerbehandlung und Dateien | Latin-1 liest still `GrÃ¶sse`; JSON macht aus Schlüssel 7 den Text `'7'` |
| R-Grundlagen | 6 mal 2 recycelt ohne Warnung; `as.numeric(factor(c(5,3,4)))` gibt 3 1 2 |
| NumPy und SciPy | `m - colMeans(m)` zentriert in R still falsch; `uint8` 200+100 = 44 |
| pandas | pandas 3: Kettenzuweisung wirkungslos; `groupby` verwirft NaN-Schlüssel; doppelter Join-Schlüssel 24 auf 36 Zeilen |
| Pakete und Umgebungen | eigene `random.py` verdeckt die Standardbibliothek; `"2.10.0" > "2.9.0"` ist falsch |
| Reproduzierbarkeit | Seed 42 in R und Python ergibt verschiedene Folgen, Lehmer identische |

Neue Stolpersteine in `build-fehler.md`: Rückgabewerte von `write()` an `_`
zuweisen. Weitere Erfahrungen dieses Umbaus:

- **Inline-R** (`` `r ...` ``) wertet knitr überall im Fliesstext aus. Soll
  er als Beispiel sichtbar bleiben, gehört er in einen ````` ````{verbatim} `````-Block.
- **Plattformabhängige Zahlen** (Dateigrösse mit `\n`, Fehlerposition)
  nicht unter Windows vorrechnen und in den Text schreiben: Der Build läuft
  unter Linux.
- **Zeitmessungen** nie als Zahl in den Text; sie schwanken je Lauf.
- **Die pandas-Version im Build ist nicht stabil.** Zwei Builds am selben
  Abend installierten pandas 3.0.5 und 2.3.3 (die Action bindet keine
  Versionen, und `scikit-learn<1.6` zieht die Auflösung mal hierhin, mal
  dorthin). Text zu versionsabhängigem Verhalten (Warnungsnamen, `str` gegen
  `object`) deshalb versionsneutral schreiben, oder pandas in `publish.yml`
  festschreiben. Python 3.12 und NumPy 2.5.3 waren in beiden Builds gleich.

### Der Visualisierungsbereich ist abgeschlossen

Build grün, `pruefe-zahlen.py` meldet alle zehn Codeseiten ohne Befund, und in
keiner Ausgabe steht ein verirrtes matplotlib-Objekt. R und Python liefern
durchgängig identische Zahlen.

Bekannte Stolpersteine dieses Bereichs stehen in `build-fehler.md`:
matplotlib-Rückgabewerte an `_` zuweisen, `unname()` vor dem Benennen in
`c()`, keine Variable `t` in R, und ein Render-Log-Commit der Action bedeutet
einen abgebrochenen Build.

### Was der Bereich jetzt kann

Jede Behauptung hat eine Kennzahl. Die tragenden Beispiele:

| Seite | Kennzahl |
|---|---|
| Wahrnehmung | 6 von 10 Winkelpaaren unter 10 Grad; Radiuskodierung macht 8-fach zu 64-fach |
| Diagrammwahl | 79.6 Prozent verdeckte Punkte; Rangkorrelation 1.0 auf 0.3 |
| Irreführung | Achse ab 95 verzerrt 5.70-fach; 40 Prozent Scheinkorrelation bei Irrfahrten |
| Farbe | Okabe-Ito hält dE 26.4; Rot-Grün fällt unter Deuteranopie von 119.8 auf 8.2 |
| Zielbild | 3 von 45 Paaren signifikant bei reinem Rauschen |
| Storytelling | Betonung 1.45 auf 10.66; Kampagneneffekt +4.56 mit p = 0.22 |
| ggplot2 | Steigungen je Typ 2.384 bis 2.534 gegen 2.358 gesamt |
| matplotlib | Log-Achse: jede Verdopplung 0.3010; 300 dpi sind 2100 x 960 Pixel |
| seaborn | 4 gegen 11 Codezeilen; 90 Ansichten aus vier Filtern |
| Dashboards | dieselbe Schwelle: 29.4 gegen 0 Prozent Alarme je nach Takt |

### Danach

Offen sind noch `werkzeuge/` (Linux und Shell, Git, Docker) und `ki/` (gar
kein Code).

Für `werkzeuge/` gilt dieselbe Frage wie bei den Serverdatenbanken: Was läuft
im Build wirklich? Shell-Befehle lassen sich über `system()` beziehungsweise
`subprocess` echt ausführen, Git-Befehle in einem temporären Repository
ebenfalls (Git ist auf dem Runner vorhanden). Docker läuft im Build nicht und
bleibt deshalb bei Listings, wie die Serverdatenbanken.

### Der Datenbankbereich

Vier Seiten rechnen echt gegen eine SQLite-Datenbank, die im Chunk entsteht:
SQL, Datenmodellierung, Datenbankzugriff und SQLite. Vier Seiten (DuckDB,
PostgreSQL, MySQL, MongoDB) haben im Build kein System und bleiben bei
Listings; sie wurden nur strukturell angeglichen und tragen jetzt einen
Hinweis, dass dort nichts gerechnet wird.

| Seite | Befund |
|---|---|
| SQL | `INNER JOIN` 10 gegen `LEFT JOIN` 11 Zeilen; `AVG` teilt durch 3 statt 6; `rabatt <> 5.0` findet 2 statt 5; `NOT IN` mit `NULL` liefert gar nichts |
| Datenmodellierung | SQLite prüft Fremdschlüssel nur mit `PRAGMA foreign_keys = ON`; zwei `NULL` in einer `UNIQUE`-Spalte sind erlaubt; eine Änderung in einer Zeile erzeugt zwei Kategorieleiter |
| Datenbankzugriff | `x' OR '1'='1` liefert zusammengebaut alle Zeilen, als Parameter keine; nach dem Transaktionsabbruch stehen unverändert zehn Zeilen da |
| SQLite | `SUM` über eine Spalte mit Text ergibt 45.7 statt eines Fehlers; `STRICT` lehnt ihn ab; `SCAN` wird mit Index zu `SEARCH` |

**Beim Schreiben gelernt:** `PRAGMA foreign_keys` wirkt **nicht** in einer
offenen Transaktion. In Python öffnet `sqlite3` nach jedem `INSERT` oder
`DELETE` implizit eine, also gehört ein `commit()` davor, sonst läuft das
Beispiel still falsch.

## Der Lehmer-Generator als Standardweg für Beispieldaten

Für grössere Datensätze hat sich der Lehmer-Generator gegenüber den
umsortierten Quantilen durchgesetzt, weil er beliebig viele **unkorrelierte**
Ströme liefert, ohne dass man Faktoren suchen muss:

```r
lehmer <- function(saat, anzahl) {
  s <- saat; raus <- numeric(anzahl)
  for (k in seq_len(anzahl)) { s <- (16807 * s) %% 2147483647; raus[k] <- s / 2147483647 }
  raus
}
normalwerte <- function(saat, anzahl, mittel = 0, streuung = 1)
  mittel + streuung * qnorm(lehmer(saat, anzahl))
```

In Python identisch mit `stats.norm.ppf`. Daraus lassen sich auch andere
Verteilungen bilden: gleichverteilt `von + (bis - von) * u`, exponentiell
`-log(u) / rate`, binär `u < p`.

**Verschiedene Saaten für verschiedene Variablen**, sonst sind sie identisch.
Der Generator hat eine Periode von gut zwei Milliarden, überlappende Ströme sind
bei den hier verwendeten Längen kein Thema.

**Aber:** Eine Saat je Spalte reicht nicht, sobald mehrere Ströme
*zusammengerechnet* werden (Quadratsummen, Kovarianzmatrizen, Distanzen über
viele Merkmale). Der Generator ist multiplikativ, aus der Saat `s` entsteht
`16807^k * s mod m`; zwei Saaten im Verhältnis 2:1 liefern deshalb linear
abhängige Ströme (gemessen: 101 und 202 korrelieren mit **0.584**). Für
mehrdimensionale Daten **einen langen Strom ziehen und umformen**:

```r
normalmatrix <- function(saat, zeilen, spalten)
  matrix(qnorm(lehmer(saat, zeilen * spalten)), nrow = zeilen, byrow = TRUE)
```

```python
def normalmatrix(saat, zeilen, spalten):
    return stats.norm.ppf(lehmer(saat, zeilen * spalten)).reshape(zeilen, spalten)
```

Der Fehler bleibt in Mittelwert und Varianz **unsichtbar** und zeigt sich erst
in Schiefe, Wölbung oder einem Ablehnanteil — siehe `build-fehler.md`,
Eintrag vom 11.09.2026.

## Bekannte Abweichungen zwischen R und Python

Diese Unterschiede sind echt und gehören auf den Seiten benannt, nicht
weggerechnet:

| Stelle | Abweichung |
|---|---|
| `scale()` gegen `StandardScaler` | R teilt durch die Standardabweichung mit Nenner n-1, Python mit n. Alle quadrierten Abstände unterscheiden sich um n/(n-1); Anteile und Aufteilungen bleiben gleich. |
| `psych::fa` gegen `factor_analyzer` | Ladungen stimmen auf drei Stellen, Kommunalitäten weichen um Tausendstel ab; bei obliquer Rotation sind die Varianzanteile ohnehin nicht eindeutig definiert. |
| `cluster::daisy` gegen selbstgebautes Gower | Geordnete Faktoren nach Podani (Ränge mit Bindungen) gegen schlichte Rangdifferenz. |
| `survfit` gegen `KaplanMeierFitter` | Konfidenzband auf der Log- gegen die Log-Log-Skala. Mit `conf.type = "log-log"` stimmen sie überein. |
| `clusGap` gegen selbstgebaute Gap-Statistik | `clusGap` zieht seine Referenzdaten zufällig; für reproduzierbare Zahlen selbst implementieren. |
| Median ohne Erreichen von 0.5 | R gibt `NA`, Python `inf`. |

## Zwei offene Kleinigkeiten

- **Glossar in der Navigation.** Die `<span class="glossary-term">` stehen
  weiterhin im HTML von Seitenleiste, Brotkrumenpfad und Reiterbeschriftungen;
  `styles.scss` macht sie unsichtbar und klickdurchlässig. Der Filter in
  `glossary.lua` greift dort nicht, weil Quarto diese Elemente einbaut, bevor
  die Filter laufen. Sichtbar ist nichts mehr; wer sauberes HTML will, muss der
  Sache noch nachgehen.
- **Mermaid-Diagramme bekommen keine Abbildungsnummer**, obwohl `fig-cap`
  gesetzt ist. Kosmetisch.
