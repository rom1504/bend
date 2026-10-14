#!/usr/bin/env python3
"""Replace only five exact table-builder definitions in frozen native89 source."""
import hashlib
import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
assert len(sys.argv) == 3, 'make-source.py FROZEN_SOURCE NEW_SOURCE'
source, output = map(Path, sys.argv[1:])
assert not output.exists() and not output.with_suffix(output.suffix + '.derivation.json').exists()
pin = lambda p: dict(file=str(p.resolve()), sha256=hashlib.sha256(p.read_bytes()).hexdigest(), bytes=p.stat().st_size)
assert pin(source)['sha256'] == '4584cf083d9eddad6f1290c9472c3aac2708099caa716a27f5b53fbcbaee1618'
baseline, candidate = (HERE / 'baseline.bend').read_text(), (HERE / 'tables.bend').read_text()
original = source.read_text()
result = original
changes = []


def definition(text, name):
    pattern = r'(?m)^@unsafe\ndef ' + re.escape(name) + r'\([^\n]*\) -> String:\n(?:  [^\n]*\n|\n)*'
    matches = list(re.finditer(pattern, text))
    assert len(matches) == 1, (name, len(matches))
    return matches[0]


for name in ['nb_seg_ids', 'nb_arities', 'nb_result_words', 'nb_flags', 'nb_dispatch']:
    old = definition(baseline, name + '_go').group().rstrip()
    hit = definition(result, name + '_go')
    assert hit.group().rstrip() == old, 'Frozen definition differs: ' + name
    helper = definition(candidate, name + '_chunks').group().rstrip()
    wrapper = definition(candidate, name + '_go').group().rstrip()
    replacement = helper + '\n\n' + wrapper + '\n\n'
    changes.append(dict(name=name + '_go', old=hit.group(), new=replacement))
    result = result[:hit.start()] + replacement + result[hit.end():]

reversed_text = result
for change in reversed(changes):
    assert reversed_text.count(change['new']) == 1
    reversed_text = reversed_text.replace(change['new'], change['old'], 1)
assert reversed_text == original, 'Unexpected outside-definition edits'
output.write_text(result)
report = dict(kind='phase90-five-table-functions-assembly', complete=True, acquisitionComplete=False,
    inputs=[pin(source), pin(HERE / 'baseline.bend'), pin(HERE / 'tables.bend'), pin(Path(__file__))],
    output=pin(output), functions=[c['name'] for c in changes], exactOutsideDefinitions=True,
    nativeEqualityPreserved=True, preserved='All other source bytes, including Phase88 equality and Phase89 owned/chunk compiler changes.')
output.with_suffix(output.suffix + '.derivation.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(report['output']))
