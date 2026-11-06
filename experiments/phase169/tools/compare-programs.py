#!/usr/bin/env python3
"""Offline product identity for the frozen hosted/native six-family acquisition."""
import hashlib
import json
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RUN = ROOT/'selfhost/build/phase169'
def pin(path):
    path = Path(path).resolve()
    raw = path.read_bytes()
    return dict(file=str(path),bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())
def loadable(path):
    raw = Path(path).read_bytes()
    assert raw[:6] == b'\x7fELF\x02\x01'
    offset = struct.unpack_from('<Q',raw,32)[0]
    size,count = struct.unpack_from('<HH',raw,54)
    assert size == 56
    rows = []
    for i in range(count):
        header = struct.unpack_from('<IIQQQQQQ',raw,offset+i*size)
        if header[0] == 1:
            start,length = header[2],header[5]
            assert start+length <= len(raw)
            rows.append((header,hashlib.sha256(raw[start:start+length]).hexdigest()))
    assert rows
    return rows
names = ['editdist','tree-bitonic','lexer','test-rle-roundtrip','test-map-set-ops','raytrace']
rows = []
for name in names:
    paths = [RUN/'cold-programs01'/name/'machine/report.json',
             RUN/'quality-six-native01'/name/'candidate/machine/report.json']
    reports = [json.loads(p.read_text()) for p in paths]
    assert all(r['complete'] for r in reports)
    equal = {}
    for field in ['sourceIR','assembly','object','runtime','binary']:
        for r in reports: assert pin(r[field]['file']) == r[field]
        equal[field] = all(reports[0][field][k] == reports[1][field][k]
                           for k in ['bytes','sha256'])
    equal['mappedElf'] = loadable(reports[0]['binary']['file']) == loadable(reports[1]['binary']['file'])
    rows.append(dict(case=name,receipts=[pin(p) for p in paths],equal=equal))
out = ROOT/'experiments/phase169/quality-native-transfer02.json'
assert not out.exists()
complete = all(all(row['equal'][k] for k in ['sourceIR','assembly','object','runtime','mappedElf']) for row in rows)
out.write_text(json.dumps(dict(complete=complete,method=pin(__file__),targetExecutions=0,rows=rows,
    scope='Complete generated text/objects and mapped images; whole ELF metadata may differ.'),indent=2)+'\n')
print(json.dumps(dict(complete=complete,cases=len(rows))))
assert complete
