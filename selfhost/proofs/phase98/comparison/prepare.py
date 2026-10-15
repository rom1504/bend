#!/usr/bin/env python3
"""Freeze exact D04 string helpers and the Phase98 comparison laws; no targets."""
import argparse
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
SOURCE = ROOT / 'selfhost/build/phase92/upstream-checked01/compiler.bend'
SOURCE_SHA = 'd04ad79cf08c019b509cfbbd4be2b16ae9e4af189767715d12e0645b9eee8097'


def pin(path):
    path = Path(path)
    data = path.read_bytes()
    return dict(file=str(path.resolve()), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--kind', choices=['baseline','held','literal'], default='baseline')
    parser.add_argument('--candidate', type=Path)
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(ROOT) and not out.exists()
    assert (args.kind == 'baseline') == (args.candidate is None)
    source_pin = pin(SOURCE); assert source_pin['sha256'] == SOURCE_SHA
    text = SOURCE.read_text()
    declarations = list(re.finditer(r'(?m)^(?:@unsafe\n)?(?:type|def|law) ([\w.]+)\b', text))
    definitions = []
    for name in ['p88_string_eq_go', 'p88_string_eq']:
        hits = [(i, m) for i,m in enumerate(declarations) if m.group(1) == name]
        assert len(hits) == 1
        index, match = hits[0]
        end = declarations[index+1].start() if index+1 < len(declarations) else len(text)
        body = text[match.start():end]
        assert '@unsafe' not in body
        definitions.append(dict(name=name, startByte=match.start(), endByte=end,
                                startLine=text[:match.start()].count('\n')+1, exactBody=body))
    out.mkdir(parents=True)
    (out/'production.bend').write_text('import Base\n\n'+''.join(row['exactBody'] for row in definitions))
    for name in ['reference.bend', 'baseline.bend']:
        (out/name).write_bytes((HERE/name).read_bytes())
    extra = []
    candidate = None
    if args.candidate:
        candidate = pin(args.candidate)
        body = args.candidate.read_bytes()
        assert b'@unsafe' not in body and b'import ' not in body
        (out/'candidate.bend').write_bytes(b'import Base\n\n'+body)
        proof = args.kind+'.bend'
        (out/proof).write_bytes((HERE/proof).read_bytes())
        extra = ['candidate.bend', proof]
    (out/'prepare.py').write_bytes(Path(__file__).read_bytes())
    report = dict(kind='phase98-exact-consuming-string-proof', targetsRun=False,
                  source=source_pin, method=pin(__file__), definitions=definitions,
                  reference=pin(HERE/'reference.bend'), laws=pin(HERE/'baseline.bend'),
                  candidate=candidate, proofKind=args.kind,
                  outputs=[pin(out/name) for name in ['production.bend','reference.bend','baseline.bend','prepare.py',*extra]],
                  transformation='Exact declaration extraction only; no unsafe annotation removed and no helper body rewritten. Optional candidate gets only an import Base prefix.')
    (out/'manifest.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(dict(out=str(out), targetsRun=False, proofKind=args.kind)))


if __name__ == '__main__':
    main()
