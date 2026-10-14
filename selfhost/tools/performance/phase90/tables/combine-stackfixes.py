#!/usr/bin/env python3
"""Freeze selected canonical tail-loop fixes into the tables-only native source."""
import hashlib
import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
assert len(sys.argv) == 3, 'combine-stackfixes.py TABLES_ONLY_SOURCE NEW_SOURCE'
source, output = map(Path, sys.argv[1:])
assert not output.exists() and not Path(str(output) + '.derivation.json').exists()
pin = lambda p: dict(file=str(p.resolve()), sha256=hashlib.sha256(p.read_bytes()).hexdigest(), bytes=p.stat().st_size)
assert pin(source)['sha256'] == '0431ecd55fdb4d70844fba9035ed024b8a84e3c8076d078385cda96dfe1096fb'
snapshots = output.parent / (output.stem + '-inputs')
snapshots.mkdir(exist_ok=False)
functions = {'static.bend': ['ns_image_words', 'ns_image_terms'],
             'flat.bend': ['nf_wrap_segments'],
             'observer-integration.bend': ['no_entry_defs', 'no_wrap_registered']}
token = re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|#[^\n]*|[A-Za-z_][A-Za-z_0-9]*(?:\.[A-Za-z_][A-Za-z_0-9]*)*')
original = source.read_text()
table_receipt_path = Path(str(source) + '.derivation.json')
table_receipt = json.loads(table_receipt_path.read_text())
assert table_receipt['output'] == pin(source) and table_receipt['exactOutsideDefinitions']
frozen_path = Path(table_receipt['inputs'][0]['file'])
assert pin(frozen_path) == table_receipt['inputs'][0]
frozen = frozen_path.read_text()
result, changes, origins, inputs, eq_count = original, [], [], [pin(frozen_path), pin(source), pin(table_receipt_path)], 0


def definition(text, name):
    pattern = r'(?m)^@unsafe\ndef ' + re.escape(name) + r'\([^\n]*\)[^\n]*\n(?:  [^\n]*\n|\n)*'
    matches = list(re.finditer(pattern, text))
    assert len(matches) == 1, (name, len(matches))
    return matches[0]


for filename, names in functions.items():
    canonical = ROOT / 'selfhost/src/back/native' / filename
    snapshot = snapshots / filename
    snapshot.write_bytes(canonical.read_bytes())
    origins.append(pin(canonical))
    inputs.append(pin(snapshot))
    text = snapshot.read_text()
    for name in names:
        hit = definition(result, name)
        assert 'def ' + name + '_rev(' not in result, 'Helper already present'
        replacement = (definition(text, name).group().rstrip() + '\n\n' +
                       definition(text, name + '_rev').group().rstrip() + '\n\n')
        count = [0]

        def replace(match):
            if match[0] == 'String.eq':
                count[0] += 1
                return 'p88_string_eq'
            return match[0]

        replacement = token.sub(replace, replacement)
        eq_count += count[0]
        changes.append(dict(name=name, old=hit.group(), new=replacement, nativeEqualityTokens=count[0]))
        result = result[:hit.start()] + replacement + result[hit.end():]

reverse = result
for change in reversed(changes):
    assert reverse.count(change['new']) == 1
    reverse = reverse.replace(change['new'], change['old'], 1)
assert reverse == original
table_changes = []
for name in ['nb_seg_ids', 'nb_arities', 'nb_result_words', 'nb_flags', 'nb_dispatch']:
    old = definition(frozen, name + '_go').group()
    new = (definition(original, name + '_chunks').group().rstrip() + '\n\n' +
           definition(original, name + '_go').group().rstrip() + '\n\n')
    table_changes.append(dict(name=name + '_go', old=old, new=new, nativeEqualityTokens=0))
all_changes = table_changes + changes
forward = frozen
for change in all_changes:
    assert forward.count(change['old']) == 1
    forward = forward.replace(change['old'], change['new'], 1)
assert forward == result, 'Combined replacements do not exactly reproduce final source'
reverse = result
for change in reversed(all_changes):
    assert reverse.count(change['new']) == 1
    reverse = reverse.replace(change['new'], change['old'], 1)
assert reverse == frozen, 'Combined reverse proof failed'
output.write_text(result)
inputs.append(pin(Path(__file__)))
report = dict(kind='phase90-tables-and-canonical-stackfixes-assembly', complete=True, acquisitionComplete=False,
    inputs=inputs, canonicalOrigins=origins, output=pin(output), exactOutsideDefinitions=True,
    functions=[c['name'] for c in all_changes], replacements=all_changes, nativeEqualityTokens=eq_count,
    scope='Only five named canonical tail-loop fixes and their _rev helpers; exact String.eq tokens in those functions use existing native89 p88_string_eq. Table changes and every other byte preserved.')
Path(str(output) + '.derivation.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(dict(output=report['output'], nativeEqualityTokens=eq_count)))
