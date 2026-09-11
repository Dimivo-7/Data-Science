# Fehler-Guideline: was den Build schon gekippt hat

Diese Datei ist das Gedächtnis für Build-Fehler. Quarto läuft nicht lokal, der
GitHub-Build ist der einzige Test, und ein einziger fehlerhafter Chunk bricht
das Rendern der ganzen Seite ab. Damit derselbe Fehler nicht zweimal passiert,
bekommt jeder fehlgeschlagene Lauf hier einen Eintrag.

**Format je Eintrag:** Datum, Symptom (die Fehlermeldung, gekürzt), Ursache,
Regel für die Zukunft. Regeln, die sich bewähren, wandern verdichtet in die
Checkliste von `instruction.md`, Abschnitt 14.

**Ablauf nach jedem Push:**

1. Action-Log ansehen. Bei einem Fehler schreibt die Action `render.log` nach
   `main` zurück; dort steht die vollständige Meldung.
2. Fehler beheben.
3. Hier einen Eintrag anlegen, **bevor** neu gepusht wird.
4. Prüfen, ob die Regel allgemeiner formuliert eine Zeile in der Checkliste
   wert ist.

---

## Wiederkehrende Regeln

Die Kurzfassung dessen, was die Einträge unten gelehrt haben:

| Regel | Warum |
|---|---|
| Paketausgaben nie über feste Spaltennamen ansprechen, ohne beide Schreibweisen abzufangen | Bibliotheken benennen Ausgabespalten zwischen Nebenversionen um |
| Versionen in `publish.yml` nur mit Grund anheben und nur einzeln | Ein Sprung über mehrere Hauptversionen macht die Ursachensuche unmöglich |
| Beispieldaten fest eintragen oder deterministisch konstruieren, nicht ziehen | R und Python erzeugen aus demselben Seed verschiedene Zahlen; jede Zahl im Fliesstext wäre dann falsch |
| Jede Zahl im Fliesstext vor dem Push nachrechnen | Ein grüner Build heisst nur, dass der Code lief, nicht dass der Text stimmt |
| Chunk-Labels über die ganze Seite eindeutig halten | Doppelte Labels brechen das Rendern ab, und der Fehler nennt nur das Label |
| Bei verschachtelten Divs bekommt das äussere mehr Doppelpunkte | Pandoc schliesst sonst am falschen Zaun |

---

## Einträge

### 2026-09-10 — Verhalten von R vorhergesagt statt nachgesehen

**Symptom:** Kein Build-Fehler. Die Seite zu den nichtparametrischen Tests ging
grün durch, und fünf Zahlen im Fliesstext stimmten trotzdem nicht mit der
gerenderten Ausgabe überein.

| behauptet | tatsächlich ausgegeben |
|---|---|
| `Wilcoxon rank sum test with continuity correction` | `Wilcoxon rank sum exact test` |
| p = 0.00014 | p = 0.00005774 |
| Warnung `cannot compute exact p-value with ties` | keine Warnung |
| gepaart: R 0.0042, Python 0.0020 | beide 0.001953 |
| `95 percent confidence interval` | `97.7 percent confidence interval` |

**Ursache:** Die Werte stammten aus einer Nachbildung von R in Python plus einer
Annahme darüber, wann R auf die Normalapproximation ausweicht. Die Annahme war
falsch, und zwar in beide Richtungen: In einem Fall rechnete R exakt, wo ich
eine Näherung erwartet hatte, im anderen stimmten beide Sprachen überein, wo ich
eine Abweichung beschrieben hatte. Das Konfidenzniveau von 97.7 Prozent
schliesslich ist eine Eigenschaft exakter Verfahren auf diskreten Daten, an die
ich nicht gedacht hatte.

**Regel:** Zahlen, die eine **Bibliothek** ausgibt, werden nicht vorhergesagt,
sondern abgelesen. Für R heisst das: Nach dem ersten grünen Build die Ausgaben
aus `_freeze/` holen und den Text dagegen prüfen, bevor die Seite als fertig
gilt. Dafür liegt `zeige-ausgaben.py` im Repo:

```bash
python zeige-ausgaben.py _freeze/statistik/tests/<seite>/execute-results/html.json
```

Statistische Kennzahlen, die sich aus den Daten ergeben (Mittelwerte, t, F,
Konfidenzintervalle), lassen sich weiterhin vorab in Python nachrechnen. Was
sich **nicht** vorab bestimmen lässt, ist die Wahl des Verfahrens durch das
Paket, die Beschriftung der Ausgabe und alles, was von Voreinstellungen abhängt.

---

### 2026-09-10 — Glossar-Tooltip in der Reiterbeschriftung

**Symptom:** Kein Build-Fehler. Im Reiter "Beispiel 1: Unabhängigkeit, und wo
die Abweichung sitzt" war das Wort Unabhängigkeit unterstrichen und zeigte beim
Überfahren einen Glossar-Tooltip. Betroffen waren sechs Reiter auf vier Seiten.

**Ursache:** Dieselbe wie beim Glossar in der Navigation. Reitertitel entstehen
aus Überschriften; zu dem Zeitpunkt, an dem der Filter läuft, hat Quarto sie
bereits umgebaut, sodass der Ausschluss von `Header` nicht mehr greift.

**Regel:** `styles.scss` neutralisiert `.glossary-term` jetzt auch unter
`.panel-tabset > .nav-tabs`, mit `pointer-events: none`, damit der Klick den
Reiter trifft und nicht den Begriff.

**Wie es aufgefallen ist:** Beim Prüfen der gerenderten Seite mit einem
Suchmuster, das an einem `<span>` abbrach. Der vermeintliche Fehler (leere
Reitertitel) war keiner; der echte Fehler wurde nur deshalb sichtbar, weil ich
mir daraufhin das rohe HTML angesehen habe. Prüfmuster, die etwas nicht finden,
sind ein Anlass zum Nachsehen und kein Befund.

---

### 2026-09-10 — fehlender Import, Beispiel von der Nachbarseite übernommen

**Symptom:** Build rot, `render.log` meldet

```
Error in py_call_impl(...) : NameError: name 'sm' is not defined
Quitting from t-test-gepaart.qmd:243-271 [fig-b1-gp-voraussetzungen-py]
```

**Ursache:** Der QQ-Plot im Beispiel ruft `sm.qqplot()` auf. Der Setup-Chunk
von `t-test-eine-stichprobe.qmd` importiert `statsmodels.api as sm`, der von
`t-test-gepaart.qmd` nicht. Beim Übertragen des Beispielaufbaus von der einen
Seite auf die andere ist der Import nicht mitgekommen, und weil jede Seite eine
eigene Sitzung hat, faellt das erst im Build auf.

**Kosten:** Ein kompletter Build von rund acht Minuten, und alles im selben
Push blieb undeployed: Der Dark-Mode-Fix und beide umgebauten Seiten waren
nach dem roten Build nicht live.

**Regel:** Vor jedem Push `python pruefe-chunks.py` laufen lassen. Das Skript
liest die Chunks jeder Seite, sucht nach Kürzeln wie `sm.`, `pg.`, `stats.`
oder R-Funktionen wie `bptest()` und meldet, wenn der zugehörige Import
beziehungsweise `library()`-Aufruf auf der Seite fehlt. Geprüft wird pro Datei,
nicht pro Chunk, weil Quarto alle Chunks einer Seite in derselben Sitzung
ausführt.

**Beim Bau des Prüfers gelernt:** Die erste Fassung suchte die Kürzel als
blosse Zeichenkette und meldete sechs Fehlalarme, weil `sm.stats.diagnostic`
die Zeichenkette `stats.` enthaelt und `stats.norm.ppf` die Zeichenkette
`norm.ppf`. Ein Prüfer, der Fehlalarme liefert, wird nach dem dritten Mal
ignoriert und ist damit wertlos. Gesucht wird deshalb mit Wortgrenze davor.

---

### 2026-09-10 — Glossar markiert Wörter in der Navigation

**Symptom:** In der Seitenleiste links und im Brotkrumenpfad standen
Menüeinträge wie "Linux und Shell" oder "Schätzen und Konfidenzintervalle"
mit gepunktetem Unterstrich und Glossar-Tooltip mitten im Wort.

**Ursache:** `glossary.lua` markierte nicht nur den Seitentext. Der erste
Erklärungsversuch, Pandoc wende den Filter zusätzlich auf die Metadaten an,
war falsch: Ein Umbau auf `doc.blocks:walk()` änderte nichts. Tatsächlich baut
Quarto Seitenleiste, Brotkrumenpfad und Navigationsleiste als Elemente ins
Dokument ein, **bevor** die Filter aus `format.html.filters` laufen. Der Titel
einer Seite wird markiert und danach in jedes Menü übernommen.

**Regel:** Der Inhaltsfilter überspringt jetzt Container mit
Navigationskennungen und -klassen (`quarto-sidebar`, `menu-text`,
`quarto-title-breadcrumbs`, `navbar` und weitere), sowohl bei Divs als auch bei
Spans. Zusätzlich steht in `styles.scss` eine Sicherung, die `.glossary-term`
innerhalb dieser Container optisch neutralisiert. Die Sicherung ist Absicht:
Quarto kann die Klassennamen mit einer neuen Version ändern, und dann fällt
nur die Lua-Sperre aus, nicht die Darstellung.

**Was daraus zu lernen ist:** Beim ersten Fix wurde eine Vermutung über die
Ursache umgesetzt, ohne sie zu prüfen. Bei einem Werkzeug, das nur im Build
läuft, kostet jede unbelegte Vermutung einen vollen Durchlauf. Erst am Ergebnis
messen, dann die nächste Änderung.

---

### 2026-09-10 — pingouin 0.6 benennt Ausgabespalten um

**Symptom:** `KeyError: 'p-unc'` beim Rendern der ANOVA-Seite; später auf
weiteren Seiten stillschweigend die ganze Tabelle statt der ausgewählten
Spalten.

**Ursache:** pingouin hat mit Version 0.6 die Bindestriche und Prozentzeichen
aus den Spaltennamen entfernt. Aus `p-unc` wurde `p_unc`, aus `p-val` wurde
`p_val`, aus `CI95%` wurde `CI95`, aus `cohen-d` wurde `cohen_d`. Die Action
installiert pingouin ohne Versionsbindung, also kam die Umbenennung mit dem
nächsten Build von selbst.

**Regel:** Spalten aus pingouin nie direkt indizieren. Auf den Methodenseiten
steht dafür `pg_wert(tabelle, "p-val")`, das Unterstriche und Bindestriche
gleich behandelt. Wo eine Auswahl nötig ist, werden beide Schreibweisen
übergeben und nur die vorhandenen genommen (`pg_auswahl`). Dasselbe gilt
sinngemäss für jede andere Bibliothek, deren Ausgabe eine Tabelle mit
Spaltennamen ist.

---

### 2026-09-09 — GitHub Actions auf v7 angehoben, Runner hängt

**Symptom:** Der Lauf blieb ohne Fehlermeldung stehen und lief in den Timeout.

**Ursache:** Die Action-Versionen wurden in einem Zug von v4/v5 auf v7
angehoben. Welcher der Schritte hängt, war aus dem Log nicht ersichtlich, weil
gar keine Ausgabe mehr kam.

**Regel:** Versionen in `.github/workflows/publish.yml` nur mit konkretem Anlass
anheben und immer nur eine Action pro Commit. Läuft der Build danach grün, ist
die Ursache eindeutig zuzuordnen; hängt er, reicht ein Revert eines einzelnen
Commits.

---

### 2026-09-10 — Zufallszahlen machen jede Zahl im Text falsch

**Symptom:** Kein Build-Fehler. Die Seiten waren grün und die Interpretationen
trotzdem unbrauchbar: Der Text nannte Werte, die in der gerenderten Ausgabe
nicht standen, und R und Python zeigten auf derselben Seite verschiedene
Ergebnisse.

**Ursache:** `set.seed(2026)` in R und `default_rng(2026)` in Python erzeugen
verschiedene Zahlenfolgen. Aus demselben Code entstehen zwei verschiedene
Datensätze, und keiner davon ist beim Schreiben bekannt.

**Regel:** Beispieldaten auf Methodenseiten werden **fest eingetragen** oder
deterministisch konstruiert. Für kleine Beispiele stehen die Werte als Vektor
im Chunk. Für grössere Datensätze werden sie aus Quantilen der
Normalverteilung gebaut, in R `qnorm(ppoints(n))` beziehungsweise
`qnorm(((0:(n-1) * faktor) %% n + 0.5) / n)`, in Python die gleiche Formel mit
`scipy.stats.norm.ppf`. Beide Sprachen sehen dann identische Zahlen. Gezogen
wird nur noch dort, wo keine Zahl aus dem Ergebnis im Fliesstext auftaucht.

**Zusatzregel:** Ergebnisse vor dem Push lokal nachrechnen. Quarto fehlt auf
dem Rechner, Python nicht: Ein Wegwerf-venv mit `numpy scipy statsmodels
scikit-learn pingouin` genügt, um jede Zahl zu prüfen, die im Text steht.

---

### 2026-09-10 — Tabsets leeren das Inhaltsverzeichnis

**Symptom:** Kein Build-Fehler. Nach dem Umbau der Methodenseiten auf ein
aeusseres Tabset "Theorie | Beispiel 1 | ..." enthielt das Inhaltsverzeichnis
rechts nur noch zwei Eintraege: "Verstaendnisfragen" und "Verlinkte
Ressourcen". Die gesamte Theorie und alle Beispielabschnitte fehlten.

**Ursache:** Quarto nimmt **saemtliche** Ueberschriften innerhalb eines
Tabsets aus dem Inhaltsverzeichnis, nicht nur die Tab-Titel selbst. Alles, was
im Tabset steht, ist im TOC unsichtbar, und Ctrl+F findet es in geschlossenen
Tabs ebenfalls nicht. Die eingebaute Suche der Seite findet es weiterhin.

**Regel:** Auf einer Nachschlageseite gehoert nur in ein Tabset, was
nebeneinander gestellt werden soll. Der Theorieteil bleibt deshalb aus dem
Tabset heraus und steht als normale `##`-Abschnitte oben; darunter folgt
`## Beispiele` mit dem Tabset. Ergebnis: Die Theorie steht vollstaendig im
TOC, die Beispiele sind Reiter, und das TOC endet mit "Beispiele",
"Verstaendnisfragen", "Verlinkte Ressourcen".

**Wie es geprueft wird:** Nach dem Push die gerenderte Seite aufrufen und das
Inhaltsverzeichnis ansehen. Ein gruener Build sagt darueber nichts.

---

### 2026-09-10 — verschachtelte Tabsets

**Symptom:** Noch keiner; die Regel ist vorbeugend notiert, weil die
Methodenseiten seit dem Umbau zwei Tabset-Ebenen haben.

**Ursache:** Pandoc schliesst einen Div beim ersten Zaun, der mindestens so
lang ist wie der öffnende. Bekommt ein inneres Tabset gleich viele oder mehr
Doppelpunkte als das äussere, endet das äussere zu früh, und die Beispiel-Tabs
verschwinden ohne Fehlermeldung.

**Regel:** Das äussere Tabset öffnet mit `::::`, das innere mit `:::`. Die
Überschriftenebenen auf einer Methodenseite: `##` für Theorieabschnitte und für
`## Beispiele`, `###` für die Beispiel-Reiter, `####` für die Abschnitte im
Beispiel, `#####` für R und Python. In jedem Tabset steht R zuerst.

---

### 2026-09-10 — Freeze-Commit geht verloren, wenn waehrend eines Builds gepusht wird

**Symptom:** Build gruen, `gh-pages` weitergerueckt, aber zu der neu gebauten
Seite gibt es keinen aktualisierten Eintrag unter `_freeze/`. `zeige-ausgaben.py`
zeigt dann die Zahlen der **vorherigen** Fassung, ohne dass etwas darauf
hinweist. Konkret gesehen bei `statistik/ueberlebenszeit/cox-modell.qmd`: Die
Freeze-Datei war einen Tag alt und enthielt noch die Ausgaben der Fassung mit
`set.seed()`, in der R und Python verschiedene Daten hatten (245 gegen 253
Ereignisse). Beim Pruefen sah das aus wie ein schwerer Fehler auf der neuen
Seite.

**Ursache:** Die Action schiebt die Freeze-Ergebnisse nach dem Build auf `main`
zurueck. Wird in der Zwischenzeit selbst gepusht, schlaegt dieser Push fehl
(non-fast-forward) und die Freeze-Aenderungen sind weg. Die Seite selbst ist
korrekt gebaut, nur die Kopie der Ausgaben fehlt.

**Regel:** Nach einem Push nicht weiterpushen, bevor der Commit
"Freeze-Ergebnisse aktualisieren" im Log steht. Arbeit an weiteren Seiten
laeuft in der Zwischenzeit lokal weiter und wird gesammelt.

**Erkennungszeichen:** `git log -1 -- _freeze/<pfad>/execute-results/html.json`
zeigt einen aelteren Commit als den eigenen. Oder direkt:
`grep -c "<neues-chunk-label>" _freeze/<pfad>/execute-results/html.json` gibt 0.

---

### 2026-09-11 — Eine Saat je Spalte macht mehrdimensionale Beispieldaten abhaengig

**Symptom:** Auf der Seite `pruefverteilungen.qmd` sollte die Summe von zehn
quadrierten Standardnormalwerten chi-quadrat-verteilt sein. Mittelwert (9.99
gegen 10) und Varianz (21.5 gegen 20) sahen brauchbar aus, die **Schiefe** lag
aber bei 3.63 statt 0.89, und der Anteil oberhalb des 95-Prozent-Quantils bei
0.13 statt 0.05.

**Ursache:** Der Lehmer-Generator ist multiplikativ: aus der Saat `s` entsteht
die Folge `16807^k * s mod m`. Zwei Saaten, von denen die eine ein kleines
Vielfaches der anderen ist, liefern deshalb **linear abhaengige Stroeme**.
Gemessene Korrelation zweier Stroeme:

| Saatpaar | Korrelation |
|---|---|
| 1000 / 1001 | 0.030 |
| 7001 / 7002 | -0.016 |
| **101 / 202** | **0.584** |

Zusaetzlich summieren sich auch kleine Restabhaengigkeiten benachbarter Saaten
auf, sobald viele Spalten aufaddiert werden.

**Regel:** Fuer mehrdimensionale Beispieldaten **einen langen Strom ziehen und
umformen** statt eine Saat je Spalte:

```r
normalmatrix <- function(saat, zeilen, spalten)
  matrix(qnorm(lehmer(saat, zeilen * spalten)), nrow = zeilen, byrow = TRUE)
```

```python
def normalmatrix(saat, zeilen, spalten):
    return stats.norm.ppf(lehmer(saat, zeilen * spalten)).reshape(zeilen, spalten)
```

Und nie zwei Saaten waehlen, bei denen die eine ein kleines Vielfaches der
anderen ist (kein 101/202, kein 1234/2468 im selben Rechenschritt).

**Erkennungszeichen:** Mittelwert und Varianz stimmen, aber **Schiefe,
Woelbung oder ein Ablehnanteil** weichen deutlich ab. Eine Kontrolle der ersten
zwei Momente faengt diesen Fehler nicht. Gegenprobe: einen Anteil oberhalb
eines theoretischen Quantils mitrechnen — er muss das Niveau treffen.

**Bestand geprueft:** Die vorhandenen Seiten sind nicht betroffen. Die einzigen
Saatpaare im Verhaeltnis 2:1 oder 3:1 sind 1234/2468 (stetige-verteilungen,
verschiedene Beispiele) und 1414/2121/4242 (zeitreihen-grundlagen und
zensierung, verschiedene Beispiele) — nirgends im selben Rechenschritt.

---

### 2026-09-11 — Die Warteregel auf den Freeze-Commit war zweimal falsch

**Erster Anlauf.** Der Wartebefehl

```sh
until git log --oneline -2 origin/main | grep -q "Freeze-Ergebnisse aktualisieren"; do ...
```

meldete sofort Erfolg, weil der Freeze-Commit des **vorherigen** Builds noch
unter den letzten zwei Eintraegen stand. Daraufhin wurde waehrend eines
laufenden Builds gepusht — genau der Fehler von 2026-09-10.

**Zweiter Anlauf, ebenfalls falsch.** Die Nachbesserung wartete darauf, dass
das **Chunk-Label** der neuen Seite in der Freeze-Datei auftaucht. Das
geschieht nie: Quarto legt in `result.markdown` nur den gerenderten Inhalt ab,
die `#| label:`-Zeilen sind zu diesem Zeitpunkt bereits verarbeitet. Die
Warteschleife lief deshalb ins Leere, obwohl der Build laengst fertig war.

**Regel:** Auf eine **Zeichenkette aus der Ausgabe** warten, nicht auf den
Commit-Titel und nicht auf ein Chunk-Label. Am besten auf einen Namen, der nur
im `print()` bzw. in der benannten Ergebniszeile der neuen Seite vorkommt:

```sh
while true; do
  git fetch -q origin main
  treffer=$(git show origin/main:_freeze/<pfad>/execute-results/html.json 2>/dev/null \
            | grep -c "<name-aus-der-ausgabe>")
  [ "$treffer" -gt 0 ] && break
  sleep 45
done
```

Das ist zugleich der Nachweis, dass der Freeze wirklich die neue Fassung
enthaelt, und nicht nur, dass irgendein Build fertig geworden ist.

**Merksatz zum Aufbau der Freeze-Datei:** Die Ausgaben stecken unter
`result.markdown`, nicht auf der obersten Ebene. Ein `grep` auf die Rohdatei
findet sie trotzdem, weil alles in einem JSON-String liegt.

---

### 2026-09-11 — Zahlen im Text maschinell gegen die Ausgabe pruefen

**Anlass:** Der Massstab fuer `stand: fertig` ist, dass jede Zahl im Fliesstext
zur tatsaechlichen Ausgabe passt. Das von Hand fuer 50 Seiten zu behaupten, ist
keine Pruefung.

**Werkzeug:** `pruefe-zahlen.py` zieht alle Zahlen mit mindestens zwei
Nachkommastellen aus dem Fliesstext (ohne Code-Chunks und Inline-Code) und
sucht sie in der Freeze-Ausgabe. Zugelassen sind Rundung auf die gezeigten
Stellen, Prozentangaben und ein abweichendes Vorzeichen.

```sh
python pruefe-zahlen.py                     # alle Seiten
python pruefe-zahlen.py statistik/tests     # ein Verzeichnis
```

**Zwei Fallen beim Bau des Skripts, beide beim ersten Lauf aufgetreten:**

1. **Das typografische Minuszeichen.** Im Text steht `−0.354` (U+2212), in der
   Ausgabe `-0.354` (ASCII). Ohne Vergleich der Betraege meldete das Skript
   21 Seiten als fehlerhaft, die alle in Ordnung waren.
2. **Einstellige Nachkommastellen nicht pruefen.** `0.5` oder `2.0` kommen in
   jeder Ausgabe irgendwo vor; die Pruefung waere wertlos. Ab zwei Stellen ist
   die Trefferwahrscheinlichkeit gering genug, dass ein Fund etwas bedeutet.

**Ergebnis des ersten vollstaendigen Laufs:** 47 von 47 gebauten Seiten ohne
Befund. Vor jedem `stand: fertig` laufen lassen.

**Das Skript ersetzt das Lesen der Ausgabe nicht.** Beim Durchsehen der Seite
`lineare-algebra-pca.qmd` fanden sich zwei Fehler, die es nicht melden konnte:

1. **Haeufige Werte.** In der Tabelle stand fuer die Scherung die Spur `1.00`,
   richtig ist `2.00`. Beide Zahlen kommen in der Ausgabe irgendwo vor, also
   gibt es keinen Treffer zu melden. Werte mit wenigen Stellen muss man
   weiterhin von Hand abgleichen.
2. **Die Prozentregel als Hintertuer.** `0.531723` statt `0.531727` blieb
   unentdeckt, weil irgendein anderer Wert mal 100 zufaellig passte. Behoben:
   Die Umrechnung mit 100 ist jetzt nur noch bis drei Nachkommastellen
   erlaubt.

**Reihenfolge, die sich bewaehrt hat:** erst `zeige-ausgaben.py` lesen, dann
`pruefe-zahlen.py` als Netz darunter.
