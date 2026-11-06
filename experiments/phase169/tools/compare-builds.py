#!/usr/bin/env python3
"""Authenticate native receipts and compare products, including mapped ELF bytes."""
import argparse
import hashlib
import json
import struct
from pathlib import Path

def pin(path):
    path = Path(path).resolve()
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())

def verify(item):
    assert pin(item['file']) == item, item['file']

def mapped(image):
    raw = Path(image['file']).read_bytes()
    assert raw[:6] == b'\x7fELF\x02\x01', 'Expected little-endian ELF64'
    start = struct.unpack_from('<Q', raw, 32)[0]
    size, count = struct.unpack_from('<HH', raw, 54)
    assert size == 56
    rows = []
    for index in range(count):
        kind, flags, offset, address, physical, length, memory, align = struct.unpack_from(
            '<IIQQQQQQ', raw, start+index*size)
        if kind == 1:
            assert offset+length <= len(raw)
            rows.append(dict(flags=flags, address=address, physical=physical,
                offset=offset, fileBytes=length, memoryBytes=memory, alignment=align,
                sha256=hashlib.sha256(raw[offset:offset+length]).hexdigest()))
    assert rows
    return rows

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--left', type=Path, required=True)
p.add_argument('--right', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
assert not a.out.exists()
reports = [json.loads(path.read_text()) for path in [a.left,a.right]]
assert all(r['complete'] for r in reports)
products = {}
for key in ['assembly','object','binary']:
    for r in reports: verify(r[key])
    products[key] = all(reports[0][key][field] == reports[1][key][field]
                        for field in ['bytes','sha256'])
products['qbe'] = reports[0]['irDigest'] == reports[1]['irDigest']
segments = [mapped(r['binary']) for r in reports]
products['mappedElf'] = segments[0] == segments[1]
result = dict(complete=all(products[k] for k in ['qbe','assembly','object','mappedElf']),
    inputs=[pin(__file__),pin(a.left),pin(a.right)], targetExecutions=0,
    equal=products, mappedSegments=segments,
    scope='Exact generated products and loadable image bytes; no semantic correctness theorem.')
a.out.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(complete=result['complete'],equal=products)))
assert result['complete']
