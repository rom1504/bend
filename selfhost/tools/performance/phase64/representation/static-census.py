#!/usr/bin/env python3
"""Source-only KTerm representation boundary inventory; executes no compiler."""
import argparse
import hashlib
import json
import re
from pathlib import Path

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--source', type=Path, default=Path('selfhost/src'))
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
assert not a.output.exists(), 'Preserve consumed evidence; use a new output'
files, arms, calls = [], [], {n: 0 for n in ['ka_wrap', 'kid', 'ks', 'kt']}
for path in sorted(a.source.resolve().rglob('*.bend')):
    data = path.read_bytes()
    source = data.decode()
    files.append({'file': str(path), 'sha256': hashlib.sha256(data).hexdigest(), 'bytes': len(data)})
    functions = list(re.finditer(r'^def\s+(\w+)\b', source, re.M))
    for match in re.finditer(r'case KTerm\{', source):
        owner = next((f.group(1) for f in reversed(functions) if f.start() < match.start()), None)
        arms.append({'file': str(path), 'line': source[:match.start()].count('\n') + 1, 'function': owner})
    for name in calls:
        calls[name] += len(re.findall(r'\b' + name + r'\s*\(', source))
result = {'kind': 'phase64-static-representation-boundary', 'dataOnly': True,
          'targetExecuted': False, 'files': files, 'explicitKTermMatchArms': arms,
          'syntacticOccurrencesIncludingDefinitions': calls,
          'scope': 'Text census only; includes definitions/comments and is not a dynamic operation count or performance prediction.'}
a.output.parent.mkdir(parents=True, exist_ok=True)
with a.output.open('x') as stream:
    json.dump(result, stream, indent=2)
    stream.write('\n')
print(json.dumps({'matchArms': len(arms), 'matchFiles': len({x['file'] for x in arms}), 'calls': calls}))
