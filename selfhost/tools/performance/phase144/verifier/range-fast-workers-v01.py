"""Bounded static function comparison; read ELF/assembly, execute no targets."""
import difflib
import hashlib
import json
from pathlib import Path
import re
import struct

ROOT = Path(__file__).resolve().parents[5]
OUT = ROOT/'selfhost/build/phase144/range-fast-worker-audit01'


def pin(p):
    p = Path(p).resolve()
    h = hashlib.sha256()
    size = 0
    with p.open('rb') as f:
        while b := f.read(1024*1024):
            h.update(b)
            size += len(b)
    return dict(file=str(p), bytes=size, sha256=h.hexdigest())


def decode(n):
    prefix = 'p113d_FID_'
    return ''.join(chr(int(x)) for x in n[len(prefix):].split('_') if x) if n.startswith(prefix) else n


def elf(path):
    b = Path(path).read_bytes()
    assert b[:6] == b'\x7fELF\x02\x01'
    h = struct.unpack_from('<HHIQQQIHHHHHH', b, 16)
    sh = [struct.unpack_from('<IIQQQQIIQQ', b, h[5]+i*h[10]) for i in range(h[11])]
    found = {}
    for s in sh:
        if s[1] != 2:
            continue
        st = sh[s[6]]
        names = b[st[4]:st[4]+st[5]]
        for pos in range(s[4], s[4]+s[5], s[9]):
            nm, info, other, idx, value, size = struct.unpack_from('<IBBHQQ', b, pos)
            if info & 15 != 2 or not 0 < idx < len(sh):
                continue
            name = names[nm:names.index(b'\0', nm)].decode()
            start = sh[idx][4]+value-sh[idx][3]
            found[name] = dict(bytes=size, sha256=hashlib.sha256(b[start:start+size]).hexdigest(), offset=value)
    return found


def assembly(path, names, capture):
    hashes, blocks = {}, {}
    active, digest, labels, parts = None, None, None, None
    with Path(path).open() as f:
        for line in f:
            if active is None:
                if line.endswith(':\n') and line[:-2] in names:
                    active = line[:-2]
                    digest, labels, parts = hashlib.sha256(), {}, []
                else:
                    continue
            if line.startswith('.size '+active+','):
                hashes[active] = digest.hexdigest()
                if active in capture:
                    blocks[active] = ''.join(parts)
                active = None
                continue
            if line.startswith('.type '):
                continue
            def label(m):
                s = m[0]
                if s not in labels:
                    labels[s] = '.Llocal'+str(len(labels))
                return labels[s]
            normalized = re.sub(r'\.Lbb[0-9]+\b', label, line)
            digest.update(normalized.encode())
            if active in capture:
                parts.append(normalized)
    assert set(hashes) == names
    return hashes, blocks


assert OUT.exists() and not (OUT/'report.json').exists()
receipts = [ROOT/'selfhost/build/phase134/p144-final03-n2/report.json',
            ROOT/'selfhost/build/phase134/p144-range-fast-final03-product01/report.json']
rs = [json.loads(p.read_text()) for p in receipts]
assert all(r['complete'] for r in rs) and rs[0]['source'] == rs[1]['source'] and rs[0]['runtime'] == rs[1]['runtime']
inputs = [pin(__file__), *map(pin, receipts), rs[0]['source'], rs[0]['runtime']]
for r in rs:
    inputs += [r['object'], r['assembly']]
for p in inputs:
    assert pin(p['file']) == p
objs = [elf(r['object']['file']) for r in rs]
assert set(objs[0]) == set(objs[1])
raw_changed = {n for n in objs[0] if objs[0][n]['sha256'] != objs[1][n]['sha256']}
asm = [assembly(r['assembly']['file'], set(objs[0]), raw_changed) for r in rs]
changed = [n for n in objs[0] if asm[0][0][n] != asm[1][0][n]]
rows = []
for i, name in enumerate(changed):
    assert name in raw_changed
    left, right = asm[0][1][name], asm[1][1][name]
    stem = f'{i:02d}'
    for suffix, text in [('baseline.s', left), ('candidate.s', right),
                         ('diff', ''.join(difflib.unified_diff(left.splitlines(True), right.splitlines(True), fromfile='baseline', tofile='candidate')))]:
        (OUT/(stem+'.'+suffix)).write_text(text)
    rows.append(dict(symbol=name, name=decode(name), baseline=objs[0][name], candidate=objs[1][name],
        baselineAssembly=pin(OUT/(stem+'.baseline.s')), candidateAssembly=pin(OUT/(stem+'.candidate.s')), diff=pin(OUT/(stem+'.diff'))))
for p in inputs:
    assert pin(p['file']) == p
report = dict(kind='phase144-range-fast-static-worker-audit', complete=True, targetsRun=False,
    inputs=inputs, functions=len(objs[0]), rawObjectChanged=len(raw_changed),
    normalizedAssemblyChanged=len(changed), rawChangesWithSameAssembly=len(raw_changed-set(changed)),
    changed=rows, scope='Read exact same-source generated ELF/assembly only. Normalize function-local .Lbb label numbers only; preserve every instruction/register/immediate/external-symbol/data reference. Same normalized assembly with different object bytes identifies assembler layout/relative-address effects, not changed QBE instruction selection.')
(OUT/'report.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(dict(report=pin(OUT/'report.json'), functions=report['functions'],
    rawChanged=len(raw_changed), normalizedChanged=len(changed), changed=[dict(name=r['name'], before=r['baseline']['bytes'], after=r['candidate']['bytes']) for r in rows])))
