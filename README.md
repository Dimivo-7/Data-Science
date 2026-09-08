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

4. **Push → fertig.** Der Workflow rendert bei jedem Push auf `main` automatisch und veröffentlicht auf `gh-pages`.

## Neues CAS-Modul aktiv ausbauen (sobald es losgeht)

1. Im entsprechenden Ordner (z.B. `cas-ml/`) Unterordner + Lektionsseiten anlegen, analog zu `cas-statda-davi/statda/`
2. In `_quarto.yml` unter `sidebar: contents:` die neuen Seiten eintragen
3. Push, fertig

## Rechenumgebung

Die Lektionsseiten enthalten ausführbare Chunks: Abbildungen und Zahlen
entstehen beim Build aus dem Code, der auf der Seite steht. Die GitHub Action
richtet dafür R und Python samt Paketen ein — siehe
`.github/workflows/publish.yml`.

Wird auf einer Seite ein neues Paket gebraucht, muss es **zuerst** dort in die
Installationsliste, sonst bricht der Build ab.

## Lokal testen (optional)

Voraussetzung: [Quarto CLI](https://quarto.org/docs/get-started/).

```bash
quarto preview
```

## Datenschutz-Hinweise

- `robots.txt` blockiert alle Crawler
- Jede Seite hat `<meta name="robots" content="noindex, nofollow, noarchive, nosnippet">`
- Trotzdem gilt: alles im Repo ist technisch öffentlich einsehbar, sobald jemand die URL kennt. Für Inhalte mit Copyright Dritter (z.B. 1:1 kopierte Prüfungsfragen oder Kursmaterialien) nicht geeignet, nur eigene Notizen/Zusammenfassungen verwenden.
