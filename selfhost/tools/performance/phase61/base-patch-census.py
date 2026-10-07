#!/usr/bin/env python3
"""Read-only frame2 census. Prints JSON; no compiler or cache mutation."""
import collections
import hashlib
import json
from pathlib import Path
import sys

def encoded(value):
    return json.dumps(value, ensure_ascii=False, separators=(',', ':')).encode()

def sequence(value):
    result = []
    while value['$'] == 'Con':
        result.append(value['head'])
        value = value['tail']
    assert value == {'$': 'Nil'}
    return result

def as_list(values):
    result = {'$': 'Nil'}
    for value in reversed(values):
        result = {'$': 'Con', 'head': value, 'tail': result}
    return result

source = Path(sys.argv[1]).resolve()
blob = source.read_bytes()
header_bytes, payload = blob.split(b'\n', 1)
header = json.loads(header_bytes)
assert header['format'] == 'bend-base-cache-frame-2'
assert sum(header['segments']) == len(payload)
parts, offset = [], 0
for count, hash_key in zip(header['segments'],
                          ['bookSha256', 'checkedPrefixStateSha256', 'freshPrefixStateSha256']):
    segment = payload[offset:offset + count]
    assert hashlib.sha256(segment).hexdigest() == header[hash_key]
    value = json.loads(segment)
    assert encoded(value) == segment
    parts.append(value)
    offset += count
raw, state, fresh = parts
assert state['$'] == 'KBasePrefixState' and state['ready'] is True
events, patches = sequence(raw), sequence(state['patches'])
final = {d['name']: d for d in events}  # Last raw declaration wins, as book_final.
assert len({d['name'] for d in patches}) == len(patches)
changes, fields, model = collections.Counter(), collections.defaultdict(collections.Counter), []
for patch in patches:
    before = final[patch['name']]
    changed = tuple(k for k in patch if patch[k] != before[k])
    changes[','.join(changed)] += 1
    for key, value in patch.items():
        equal = value == before[key]
        fields[key]['equal' if equal else 'changed'] += 1
        fields[key]['equalBytes' if equal else 'changedBytes'] += len(encoded(value))
    assert changed == ('value',)
    assert {**before, 'value': patch['value']} == patch
    model.append({'$': 'KBasePatchBody', 'name': patch['name'], 'value': patch['value']})
modeled_state = {**state, 'patches': as_list(model)}

# Nonoverlapping maximal exact KTerm subtrees. Merkle keys retain field order;
# every hit is additionally checked by structural equality including all spans.
tags = {'KTerm', 'KLambda', 'KLiteral'}
metadata = {}
def fold(value, index=None):
    if isinstance(value, dict):
        children, size = [], 2 + max(0, len(value) - 1)
        for key, child in value.items():
            digest, count = fold(child, index)
            key_bytes = encoded(key)
            size += len(key_bytes) + 1 + count
            children.append(key_bytes + b':' + digest)
        digest = hashlib.sha256(b'{' + b','.join(children) + b'}').digest()
        metadata[id(value)] = (digest, size)
        if index is not None and value.get('$') in tags:
            index[digest].append(value)
        return digest, size
    data = encoded(value)
    return hashlib.sha256(data).digest(), len(data)

def reused(value, index):
    if not isinstance(value, dict):
        return 0, 0
    if value.get('$') in tags:
        digest, size = metadata[id(value)]
        if any(value == old for old in index.get(digest, [])):
            return 1, size
    nodes = size = 0
    for child in value.values():
        n, b = reused(child, index)
        nodes += n
        size += b
    return nodes, size

all_raw = collections.defaultdict(list)
for definition in final.values():
    fold(definition, all_raw)
rows = []
for patch in patches:
    local = collections.defaultdict(list)
    fold(final[patch['name']]['value'], local)
    fold(patch['value'])
    same, anywhere = reused(patch['value'], local), reused(patch['value'], all_raw)
    rows.append({'name': patch['name'], 'bodyBytes': len(encoded(patch['value'])),
                 'localExactNodes': same[0], 'localExactBytes': same[1],
                 'globalExactNodes': anywhere[0], 'globalExactBytes': anywhere[1]})
assert source.read_bytes() == blob
report = {
    'kind': 'phase61-read-only-base-patch-census',
    'input': {'file': str(source), 'bytes': len(blob), 'sha256': hashlib.sha256(blob).hexdigest()},
    'producer': {'file': str(Path(__file__).resolve()),
                 'sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest()},
    'frame': {'headerBytes': len(header_bytes) + 1, 'segmentBytes': header['segments']},
    'rawEvents': len(events), 'finalRawDeclarations': len(final), 'checkedPatches': len(patches),
    'changedFieldGroups': dict(changes), 'fields': dict(fields),
    'bodyOnlyModel': {'stateBytes': len(encoded(modeled_state)),
                     'savedBytes': len(encoded(state)) - len(encoded(modeled_state)),
                     'exactRawPlusBodyReconstruction': True, 'codecImplemented': False},
    'bodySubtrees': {k: sum(row[k] for row in rows) for k in rows[0] if k != 'name'},
    'largestBodies': sorted(rows, key=lambda row: -row['bodyBytes'])[:5],
    'scope': 'Serialized bytes, not heap allocation or timing. Existing cache provenance only; no fresh checker run.',
}
print(json.dumps(report, indent=2))
