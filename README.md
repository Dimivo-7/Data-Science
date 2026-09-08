# MAS Data Science – Meine Notizen

Private Lern- und Nachschlageseite für den gesamten MAS Data Science (FFHS), gebaut mit Quarto. Öffentliches Repo, aber nicht gelistet/nicht indexiert – nur erreichbar für alle, die den Link kennen.

## Struktur

```
index.qmd                          MAS-Übersicht
cas-grundlagen/                    Platzhalter (noch nicht besucht)
cas-statda-davi/                   aktuelles CAS, aktiv ausgebaut
  statda/                          5 Lektionen: Regression, Hypothesis Testing, PCA/EFA, Clustering, Time Series
  davi/                            5 Lektionen: Grundlagen, R (ggplot2), Python (matplotlib/seaborn/plotly), Dashboards, Storytelling
cas-ml/                            Platzhalter
cas-dea/                           Platzhalter
cas-ai-eng/                        Platzhalter
cas-adv-ml/                        Platzhalter
masterthesis/                      Platzhalter
```

Jede Lektion hat einen R- und Python-Tab nebeneinander (`panel-tabset`), damit beide Sprachen parallel sichtbar sind.

## Einmaliges Setup

1. **Repo auf GitHub anlegen**
   - Public (Pflicht für kostenlose GitHub Pages)
   - **Keine** Description, **keine** Topics setzen, das hält es aus der GitHub-Suche raus
   - Namen unauffällig wählen

2. **Diesen Ordner pushen**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/DEIN-USERNAME/DEIN-REPO.git
   git push -u origin main
   ```

3. **GitHub Pages aktivieren**: Settings → Pages → Source: `gh-pages` / `root` (Branch entsteht beim ersten Actions-Lauf automatisch)

4. **Discussions aktivieren**: Settings → General → Features → Häkchen bei "Discussions"

5. **Giscus einrichten**: auf https://giscus.app Repo-Namen eingeben, Kategorie "Comments", die generierten `repo-id` und `category-id` in `_quarto.yml` eintragen

6. **Push → fertig.** Der Workflow rendert bei jedem Push auf `main` automatisch und veröffentlicht auf `gh-pages`.

## Neues CAS-Modul aktiv ausbauen (sobald es losgeht)

1. Im entsprechenden Ordner (z.B. `cas-ml/`) Unterordner + Lektionsseiten anlegen, analog zu `cas-statda-davi/statda/`
2. In `_quarto.yml` unter `sidebar: contents:` die neuen Seiten eintragen
3. Push, fertig

## Kommentare in den Code einbauen (dein gewählter Workflow: manuell mit Claude)

Kommentare/Ergänzungen entstehen unten auf jeder Seite über den Giscus-Kasten, komplett ohne dass du dafür eine `.qmd`-Datei anfasst. Sie landen als GitHub Discussion in deinem Repo.

Wenn du sie einbauen willst:
1. Gehe zum entsprechenden Discussion-Thread im Repo (Tab "Discussions")
2. Kopiere den Link oder den Text der relevanten Kommentare
3. Sag mir z.B.: *"Baue diese Kommentare in Lektion X ein: [Link oder eingefügter Text]"*
4. Ich lese den Thread (bei öffentlichem Repo direkt über den Link möglich), formuliere die Ergänzung sauber in die passende Stelle der `.qmd`-Datei ein und du committest/pushst danach wie gewohnt

So bleibt die Trennung klar: Rohkommentare sammeln sich unabhängig vom Code, die eigentliche Seite ändert sich erst, wenn du das aktiv anstösst.

## Lokal testen (optional)

Voraussetzung: [Quarto CLI](https://quarto.org/docs/get-started/).

```bash
quarto preview
```

## Datenschutz-Hinweise

- `robots.txt` blockiert alle Crawler
- Jede Seite hat `<meta name="robots" content="noindex, nofollow, noarchive, nosnippet">`
- Trotzdem gilt: alles im Repo ist technisch öffentlich einsehbar, sobald jemand die URL kennt. Für Inhalte mit Copyright Dritter (z.B. 1:1 kopierte Prüfungsfragen oder Kursmaterialien) nicht geeignet, nur eigene Notizen/Zusammenfassungen verwenden.
