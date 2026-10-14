#!/usr/bin/env python3
"""Offline replay of exact method edits; never overwrites old or current tools."""
import hashlib
import json
import sys
from pathlib import Path

assert len(sys.argv) == 3, 'Usage: replay-native-methods.py DERIVATION.json NEW_DIRECTORY'
manifest, out = map(Path, sys.argv[1:])
data = json.loads(manifest.read_text())
assert data['kind'] == 'phase90-native-comparison-method-derivation' and data['complete']
out.mkdir(parents=True, exist_ok=False)
for item in data['changes']:
    original = item['original']
    before = Path(original['file']).read_bytes()
    assert len(before) == original['bytes'] and hashlib.sha256(before).hexdigest() == original['sha256']
    result = before
    for edit in reversed(item['edits']):
        start, end = edit['startByte'], edit['endByte']
        assert before[start:end] == edit['old'].encode()
        result = result[:start] + edit['new'].encode() + result[end:]
    expected = item['output']
    assert len(result) == expected['bytes'] and hashlib.sha256(result).hexdigest() == expected['sha256']
    target = out / Path(expected['file']).name
    with target.open('xb') as stream:
        stream.write(result)
    print(json.dumps(dict(file=str(target.resolve()), sha256=expected['sha256'], bytes=len(result), targetExecuted=False)))
