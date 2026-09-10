# Stand und nächste Schritte

Diese Datei hält fest, wo die Arbeit steht und wie es weitergeht. Sie liegt im
Repo, damit der Stand auf jedem Rechner verfügbar ist und nicht in einem
lokalen Gedächtnis hängt.

Stand: 10. September 2026, Bereiche Tests und Regression vollständig.

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
| `statistik/multivariat/` | Hauptkomponentenanalyse |
| `referenz/` | R und Python für die verwendeten Funktionen gefüllt (Verteilungen, Hypothesentests, Regression, Multivariat, Grafik) |

## Als Nächstes

1. **`statistik/inferenz/`.** Effektstärken, Power, multiples Testen, Bootstrap
   sind Gerüste. Schätzen und Konfidenzintervalle sowie
   Hypothesentests-Grundlagen haben Inhalt, aber noch den alten Aufbau.
2. **Die übrigen Bereiche umbauen**: Multivariat (ohne PCA), Überlebenszeit,
   Zeitreihen, Grundlagen, Wahrscheinlichkeit. Sie haben Inhalt, aber noch
   Szenarien statt Beispiel-Reiter.
3. **Zwei fehlende Seiten anlegen.** Der Abgleich mit den beiden Modulplänen
   (`0_ESDS_…pdf` und `0_StatDa_…pdf`) ergab genau zwei Lücken:
   - Prüfverteilungen: t-, Chi-Quadrat- und F-Verteilung
   - Grundlagen der linearen Algebra für die Hauptkomponentenanalyse
     (Matrizen, Eigenwerte, Eigenvektoren)

## Zwei offene Kleinigkeiten

- **Glossar in der Navigation.** Die `<span class="glossary-term">` stehen
  weiterhin im HTML von Seitenleiste, Brotkrumenpfad und Reiterbeschriftungen;
  `styles.scss` macht sie unsichtbar und klickdurchlässig. Der Filter in
  `glossary.lua` greift dort nicht, weil Quarto diese Elemente einbaut, bevor
  die Filter laufen. Sichtbar ist nichts mehr; wer sauberes HTML will, muss der
  Sache noch nachgehen.
- **Mermaid-Diagramme bekommen keine Abbildungsnummer**, obwohl `fig-cap`
  gesetzt ist. Kosmetisch.
