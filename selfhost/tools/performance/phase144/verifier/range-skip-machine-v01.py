"""Read retained QBE/assembly/ELF only; never execute a compiler or program."""
import difflib
import hashlib
import json
from pathlib import Path
import re
import struct

ROOT = Path(__file__).resolve().parents[5]


def pin(path):
    path = Path(path).resolve()
    b = path.read_bytes()
    return dict(file=str(path), bytes=len(b), sha256=hashlib.sha256(b).hexdigest())


def sections_and_functions(path):
    b = Path(path).read_bytes()
    assert b[:6] == b'\x7fELF\x02\x01'
    h = struct.unpack_from('<HHIQQQIHHHHHH', b, 16)
    sh = [struct.unpack_from('<IIQQQQIIQQ', b, h[5]+i*h[10]) for i in range(h[11])]
    strings = b[sh[h[12]][4]:sh[h[12]][4]+sh[h[12]][5]]

    def name(tab, offset):
        return tab[offset:tab.index(b'\0', offset)].decode()

    sections = {name(strings, s[0]): b[s[4]:s[4]+s[5]] for s in sh if s[1] != 8}
    functions = {}
    for s in sh:
        if s[1] != 2:
            continue
        st = sh[s[6]]
        names = b[st[4]:st[4]+st[5]]
        for pos in range(s[4], s[4]+s[5], s[9]):
            nm, info, other, idx, value, size = struct.unpack_from('<IBBHQQ', b, pos)
            if info & 15 == 2 and 0 < idx < len(sh):
                offset = sh[idx][4] + value - sh[idx][3]
                functions[name(names, nm)] = b[offset:offset+size]
    return sections, functions


def qbe_functions(text):
    found = {}
    for m in re.finditer(r'^(?:export )?function[^\n]*\$([^ (]+)\([^\n]*\) \{\n', text, re.M):
        end = text.index('\n}', m.end())+2
        found[m[1]] = text[m.start():end]
    return found


builds_file = ROOT/'selfhost/build/phase144/range-skip-builds01/report.json'
timing_file = ROOT/'selfhost/build/phase144/range-skip-times01/report.json'
builds = json.loads(builds_file.read_text())
assert builds['complete']
out = ROOT/'selfhost/build/phase144/range-skip-machine01'
assert not out.exists()
out.mkdir()
inputs = [pin(__file__), pin(builds_file), pin(timing_file)]
rows = []
for case in ['lexer', 'coverage-map-churn-128', 'coverage-closures-256']:
    pair = {x['role']: x for x in builds['builds'] if x['name'] == case}
    data = {}
    for role, item in pair.items():
        receipt = json.loads(Path(item['build']['file']).read_text())
        assert receipt['complete'] and receipt['binary'] == item['binary']
        obj, exe = Path(receipt['object']['file']), Path(receipt['binary']['file'])
        asm = Path(item['build']['file']).parent/'program.s'
        qp = item['qbe']
        for p in [item['build'], item['binary'], receipt['object'], qp, item['runtime']]:
            assert pin(p['file']) == p
            inputs.append(p)
        inputs.append(pin(asm))
        data[role] = dict(object=obj, binary=exe, assembly=asm, qbe=Path(qp['file']),
                          objectData=sections_and_functions(obj), binaryData=sections_and_functions(exe))
    a, b = data['baseline'], data['candidate']
    qa, qb = a['qbe'].read_text(), b['qbe'].read_text()
    fa, fb = qbe_functions(qa), qbe_functions(qb)
    assert set(fa) == set(fb) and fa
    changed = [name for name in fa if fa[name] != fb[name]]
    diff = out/(case+'.qbe.diff')
    diff.write_text(''.join(difflib.unified_diff(qa.splitlines(True), qb.splitlines(True),
                    fromfile=str(a['qbe']), tofile=str(b['qbe']), n=3)))
    rows.append(dict(name=case, qbeBytesDelta=len(qb.encode())-len(qa.encode()),
        qbeFunctionCount=len(fa), changedQbeFunctions=changed, qbeDiff=pin(diff),
        assemblyExact=a['assembly'].read_bytes() == b['assembly'].read_bytes(),
        assemblyBytes=a['assembly'].stat().st_size,
        entireObjectExact=a['object'].read_bytes() == b['object'].read_bytes(),
        objectFunctionCount=len(a['objectData'][1]),
        changedObjectFunctions=[name for name in a['objectData'][1] if a['objectData'][1][name] != b['objectData'][1].get(name)],
        executableTextExact=a['binaryData'][0]['.text'] == b['binaryData'][0]['.text'],
        changedExecutableSections=[name for name in a['binaryData'][0] if a['binaryData'][0][name] != b['binaryData'][0].get(name)]))
for p in inputs:
    assert pin(p['file']) == p
report = dict(kind='phase144-range-skip-static-machine-equality', complete=True,
    targetsRun=False, inputs=list({x['file']: x for x in inputs}.values()), rows=rows,
    scope='Exact retained generated assembly/object byte comparisons and ELF text/function slices. This establishes identical machine output for these three programs, not arbitrary input equivalence or a whole compiler cost gain.')
(out/'report.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(dict(report=pin(out/'report.json'), rows=rows)))
