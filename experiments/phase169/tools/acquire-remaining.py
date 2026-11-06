#!/usr/bin/env python3
"""Select the39 unbuilt native45 cases; maintained acquisition owns all gates."""
import json
import subprocess
import sys
from pathlib import Path
root = Path(__file__).resolve().parents[3]
catalog = json.loads((root/'selfhost/tools/bench/catalogs/native45/catalog.json').read_text())
done = {'editdist','tree-bitonic','lexer','test-rle-roundtrip','test-map-set-ops','raytrace'}
names = [row['id'] for row in catalog['cases'] if row['id'] not in done]
assert len(catalog['cases']) == 45 and len(names) == 39
raise SystemExit(subprocess.call([sys.executable,'-B',str(root/'selfhost/tools/bench/acquire.py'),
    '--cases',','.join(names),*sys.argv[1:]],cwd=root))
