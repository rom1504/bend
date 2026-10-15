#!/usr/bin/env python3
"""Offline exact ne_segment derivative and composed native-source assembly."""
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]
PARENT = HERE.parent / 'fork01/compiler-fork.assembly.json'


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def write_json(path, value):
    with path.open('x') as stream:
        json.dump(value, stream, indent=2, ensure_ascii=False)
        stream.write('\n')


parent = json.loads(PARENT.read_text())
assert pin(PARENT)['sha256'] == '21a6140df89ff3f0757e78652ad234d37fd220fc774ff705fa289b2d2f3179ff'
assert parent['kind'] == 'phase90-native-source-assembly' and parent['complete']
assert len(parent['replacements']) == 13
for item in parent['inputs'] + [parent['output']]:
    assert pin(item['file']) == item
assert parent['output']['sha256'] == 'd8a94ce9f16e7576d2f4269c858d008e3da2f40f734cdf0983a3a9835f330791'
original = Path(parent['output']['file']).read_text()
matches = list(re.finditer(r'(?m)^@unsafe\ndef ne_segment\([^\n]*\) -> String:\n(?:  [^\n]*\n|\n)*', original))
assert len(matches) == 1
before = matches[0][0]
needle, replacement = '++ nt_indent(body) ++ "\\n"', '++ body ++ "\\n"'
assert before.count(needle) == original.count(needle) == 1
after = before.replace(needle, replacement, 1)
candidate = original.replace(before, after, 1)
assert candidate.count(after) == 1 and candidate.replace(after, before, 1) == original
source = HERE / 'compiler-noindent.bend'
with source.open('x') as stream:
    stream.write(candidate)
derivative_path = HERE / 'compiler-noindent.derivation.json'
change = dict(name='ne_segment', old=before, new=after)
derivative = dict(kind='phase90-native-ne-segment-noindent', complete=True,
    parent=parent['output'], parentAssembly=pin(PARENT), method=pin(__file__),
    output=pin(source), replacement=change, exactOutsideDefinition=True,
    inverseByteExact=True, targetExecuted=False)
write_json(derivative_path, derivative)
changes = parent['replacements'] + [change]
ancestor = Path(parent['inputs'][0]['file']).read_text()
current = ancestor
for change in changes:
    assert current.count(change['old']) == 1
    current = current.replace(change['old'], change['new'], 1)
assert current == candidate
for change in reversed(changes):
    assert current.count(change['new']) == 1
    current = current.replace(change['new'], change['old'], 1)
assert current == ancestor
assembly = dict(kind='phase90-native-source-assembly', complete=True,
    acquisitionComplete=False, exactOutsideDefinitions=True,
    inputs=parent['inputs'] + [parent['output'], pin(PARENT), pin(derivative_path), pin(__file__)],
    output=pin(source), functions=[change['name'] for change in changes],
    replacements=changes, inverseRecoversOriginal=True)
assembly_path = HERE / 'compiler-noindent.assembly.json'
write_json(assembly_path, assembly)
print(json.dumps(dict(source=pin(source), assembly=pin(assembly_path), targetExecuted=False)))
