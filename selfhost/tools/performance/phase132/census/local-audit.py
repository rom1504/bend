#!/usr/bin/env python3
"""Independent census/count join to the reversible local-name experiment."""
import argparse
import json
from pathlib import Path
from audit import pin, identity

p = argparse.ArgumentParser()
p.add_argument('--census', required=True)
p.add_argument('--locals', required=True)
p.add_argument('--out', required=True)
a = p.parse_args()
c = json.loads(Path(a.census).read_text())
l = json.loads(Path(a.locals).read_text())
assert c['complete'] and l['complete']
identity(c['inputs']['qbe'], l['source'])
assert c['functions'] == l['functions']
assert c['blocks'] == l['counts']['labelDefinitions']
assert c['symbolOccurrences']['local_symbols'] == l['counts']['variableOccurrences']
assert c['symbolOccurrences']['block_labels'] == l['counts']['labelOccurrences']
removed = l['counts']['variableBytesRemoved'] + l['counts']['labelBytesRemoved']
assert all(x['localBytesRemoved'] == removed and x['reverseSha256'] == l['source']['sha256'] for x in l['modes'])
out = Path(a.out)
assert not out.exists()
out.write_text(json.dumps({'kind': 'phase132-census-local-count-join-v1', 'complete': True,
                          'inputs': [pin(a.census), pin(a.locals), pin(__file__), pin(Path(__file__).with_name('audit.py'))],
                          'functions': c['functions'], 'blocks': c['blocks'],
                          'localOccurrences': c['symbolOccurrences']['local_symbols'],
                          'labelOccurrences': c['symbolOccurrences']['block_labels'],
                          'localAndLabelBytesRemoved': removed,
                          'scope': 'Independent scanner count and exact source identity join. Inverse-byte proof is supplied by the pinned local-name receipt; this tool does not rerun it or execute generated code.'}, indent=2) + '\n')
print(out)
