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

### 2026-09-10 — verschachtelte Tabsets

**Symptom:** Noch keiner; die Regel ist vorbeugend notiert, weil die
Methodenseiten seit dem Umbau zwei Tabset-Ebenen haben.

**Ursache:** Pandoc schliesst einen Div beim ersten Zaun, der mindestens so
lang ist wie der öffnende. Bekommt ein inneres Tabset gleich viele oder mehr
Doppelpunkte als das äussere, endet das äussere zu früh, und die Beispiel-Tabs
verschwinden ohne Fehlermeldung.

**Regel:** Das äussere Tabset öffnet mit `::::`, das innere mit `:::`. Die
Überschriftenebenen entsprechend: `##` für die Tabs Theorie und Beispiele,
`###` für die Abschnitte darin, `####` für R und Python. In jedem Tabset steht
R zuerst.
