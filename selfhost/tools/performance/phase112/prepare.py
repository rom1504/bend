#!/usr/bin/env python3
"""Transport exact Bend declarations onto frozen Phase111 source; no lowering."""
import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[4]
BASE = ROOT / 'selfhost/build/phase111/full-source05/compiler.bend'
BASE_SHA = '825cb03276c30a944ef1b1e8ed0624531253d2f39a502b0fcbfbfea3f3bb3f44'
DECL = re.compile(r'^(?:@unsafe\n)?(def|type|law) ([A-Za-z0-9_.]+)\b', re.M)


def pin(path):
    path = Path(path).resolve()
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def blocks(text):
    starts = list(DECL.finditer(text))
    return [(m.group(1), m.group(2), m.start(), starts[i+1].start() if i+1 < len(starts) else len(text))
            for i, m in enumerate(starts)]


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--module', type=Path, action='append', default=[])
    p.add_argument('--override', type=Path, action='append', default=[], help='Explicit final declaration overrides; may replace a prior module declaration')
    args = p.parse_args()
    out = args.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase112')
    assert pin(BASE)['sha256'] == BASE_SHA, 'Frozen baseline changed'
    source = BASE.read_text()
    edits = []
    overrides = {f.resolve() for f in args.override}
    modules = [f.resolve() for f in [*args.module,*args.override]]
    seen = set()
    for module in modules:
        content = module.read_text()
        for kind, name, a, b in blocks(content):
            assert (kind, name) not in seen or module in overrides, 'Repeated override needs --override: ' + name
            seen.add((kind, name))
            body = content[a:b].rstrip() + '\n\n'
            matches = [(x,y) for k,n,x,y in blocks(source) if k == kind and n == name]
            assert len(matches) <= 1, 'Ambiguous baseline declaration: ' + name
            if matches:
                x,y = matches[0]
                old = source[x:y]
                source = source[:x] + body + source[y:]
                edits.append(dict(kind=kind,name=name,action='replace',oldSha256=hashlib.sha256(old.encode()).hexdigest(),module=str(module)))
            else:
                source += '\n' + body
                edits.append(dict(kind=kind,name=name,action='append',module=str(module)))
    assert len(re.findall(r'^def main\(', source, re.M)) == 1
    out.mkdir(parents=True)
    (out/'modules').mkdir()
    snapshots=[]
    for i,module in enumerate(modules):
        dest=out/'modules'/f'{i:02d}-{module.name}'
        dest.write_bytes(module.read_bytes())
        snapshots.append(dict(original=pin(module),snapshot=pin(dest)))
    (out/'compiler.bend').write_text(source)
    (out/'method.py').write_bytes(Path(__file__).read_bytes())
    record=dict(kind='phase112-source-composition',prepared=True,checked=False,targetsRun=False,
                baseline=pin(BASE),source=pin(out/'compiler.bend'),method=pin(out/'method.py'),
                modules=[pin(f) for f in modules],moduleSnapshots=snapshots,edits=edits)
    (out/'manifest.json').write_text(json.dumps(record,indent=2)+'\n')
    print(json.dumps(dict(source=record['source'],edits=len(edits))))


if __name__ == '__main__':
    main()
