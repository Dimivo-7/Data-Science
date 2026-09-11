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
| `referenz/` | R und Python für die verwendeten Funktionen gefüllt (Verteilungen, Hypothesentests, Regression, Multivariat, Grafik) |

## Als Nächstes

Der inhaltliche Aufbau ist abgeschlossen. Was bleibt, ist Pflege:

1. **Zahlen der neuesten Seiten gegen den Freeze prüfen.** Offen sind
   `kombinatorik-wahrscheinlichkeit.qmd`, `pruefverteilungen.qmd` und
   `lineare-algebra-pca.qmd`. Vorgehen wie immer über
   `python zeige-ausgaben.py _freeze/<pfad>/execute-results/html.json`.
2. **`stand: entwurf` auf `geprueft` heben**, sobald die Zahlen einer Seite
   gegen den Freeze gezogen sind.
3. **Querverweise durchgehen.** Die neuen Seiten verlinken auf
   `hauptkomponentenanalyse.qmd`, `multiple-lineare-regression.qmd` und
   `multiples-testen.qmd`; die Gegenrichtung fehlt teilweise noch.

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
