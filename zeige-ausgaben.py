# -*- coding: utf-8 -*-
"""Zeigt alle Chunk-Ausgaben einer Freeze-Datei.

Aufruf: python zeige_ausgaben.py <html.json> [Filterwort ...]

Damit laesst sich nach dem Build pruefen, ob die Zahlen im Fliesstext mit dem
uebereinstimmen, was R und Python tatsaechlich ausgegeben haben. Ein gruener
Build sagt darueber nichts.
"""
import io
import json
import re
import sys

pfad = sys.argv[1]
filter_worte = sys.argv[2:]

d = json.load(io.open(pfad, encoding='utf-8'))
roh = json.dumps(d, ensure_ascii=False)
s = roh.replace('\\n', '\n').replace('\\t', '    ').replace('\\"', '"')

for m in re.finditer(r'cell-output-stdout.*?```\n(.*?)```', s, re.S):
    text = m.group(1).strip()
    if filter_worte and not any(w in text for w in filter_worte):
        continue
    print('-' * 58)
    print(text[:900])
