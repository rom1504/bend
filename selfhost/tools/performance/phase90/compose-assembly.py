#!/usr/bin/env python3
"""Compose an exact source74 fork derivative with the original source proof."""
import hashlib
import json
import sys
from pathlib import Path

parent_file, derivative_file, output = map(Path, sys.argv[1:])
parent = json.loads(parent_file.read_text())
derivative = json.loads(derivative_file.read_text())

def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))

for item in parent['inputs'] + [parent['output'], derivative['parent'], derivative['output']]:
    assert pin(item['file']) == item
assert parent['output'] == derivative['parent'] and derivative['inverseByteExact']
changes = list(parent['replacements'])
for item in derivative['replacements']:
    changes.append(dict(name=item['name'], old=item['before'], new=item['after']))
changes.append(dict(name='p90_fork_helpers', old=derivative['insertBefore'],
                    new=derivative['insertion'] + derivative['insertBefore']))
original = Path(parent['inputs'][0]['file']).read_text()
text = original
for item in changes:
    assert text.count(item['old']) == 1
    text = text.replace(item['old'], item['new'], 1)
assert text == Path(derivative['output']['file']).read_text()
for item in reversed(changes):
    assert text.count(item['new']) == 1
    text = text.replace(item['new'], item['old'], 1)
assert text == original
result = dict(kind='phase90-native-source-assembly', complete=True,
              acquisitionComplete=False, exactOutsideDefinitions=True,
              inputs=parent['inputs'] + [parent['output'], pin(parent_file), pin(derivative_file), pin(__file__)],
              output=derivative['output'], functions=[item['name'] for item in changes],
              replacements=changes, inverseRecoversOriginal=True)
with output.open('x') as stream:
    json.dump(result, stream, indent=2, ensure_ascii=False)
    stream.write('\n')
print(json.dumps(pin(output)))
