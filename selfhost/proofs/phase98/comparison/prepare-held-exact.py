#!/usr/bin/env python3
"""Freeze exact full-candidate held comparison declarations; no target execution."""
import argparse
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
BASE = ROOT / 'selfhost/build/phase92/upstream-checked01/compiler.bend'
CANDIDATE = ROOT / 'selfhost/build/phase98/held-source01/compiler.bend'
RECEIPT = CANDIDATE.parent / 'changes.json'


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def extract(source, names):
    matches = list(re.finditer(r'(?m)^(?:@unsafe\n)?(?:type|def|law) ([\w.]+)\b', source))
    rows = []
    for name in names:
        hits = [(i, m) for i, m in enumerate(matches) if m.group(1) == name]
        assert len(hits) == 1, name
        i, m = hits[0]
        end = matches[i+1].start() if i+1 < len(matches) else len(source)
        body = source[m.start():end]
        assert '@unsafe' not in body
        rows.append(dict(name=name, startByte=m.start(), endByte=end, exactBody=body))
    return rows


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(ROOT) and not out.exists()
    receipt = json.loads(RECEIPT.read_text())
    assert pin(BASE)['sha256'] == receipt['source']['sha256']
    assert pin(CANDIDATE)['sha256'] == receipt['candidate']['sha256']
    baseline, candidate = BASE.read_text(), CANDIDATE.read_text()
    replay = baseline
    for change in receipt['changes']:
        assert replay.count(change['old']) == 1
        replay = replay.replace(change['old'], change['new'], 1)
    assert replay == candidate
    production = extract(baseline, ['p88_string_eq_go', 'p88_string_eq'])
    changed = extract(candidate, ['p88_string_eq_go', 'P98EqHeld', 'p98_eq_finish', 'p98_eq_observe', 'p88_string_eq'])
    assert production[0]['exactBody'] == changed[0]['exactBody']
    out.mkdir(parents=True)
    for name, rows in [('production.bend', production), ('candidate.bend', changed)]:
        (out/name).write_text('import Base\n\n'+''.join(row['exactBody'] for row in rows))
    copied = ['reference.bend', 'baseline.bend', 'held-exact.bend', 'prepare-held-exact.py']
    for name in copied:
        (out/name).write_bytes((HERE/name).read_bytes())
    manifest = dict(kind='phase98-exact-full-candidate-held-proof-source', targetsRun=False,
                    source=pin(BASE), candidate=pin(CANDIDATE), receipt=pin(RECEIPT), method=pin(__file__),
                    productionDefinitions=production, candidateDefinitions=changed,
                    forwardReplayExact=True, walkerBodyUnchanged=True,
                    outputs=[pin(out/name) for name in ['production.bend','candidate.bend',*copied]],
                    entry=str(out/'held-exact.bend'),
                    scope='Exact safe full-candidate value preservation. No C lifetime or unsafe caller theorem.',
                    transformation='Exact declaration bytes plus import Base; no renamed calls or removed annotations.')
    (out/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    print(json.dumps(dict(out=str(out), entry=manifest['entry'], targetsRun=False)))


if __name__ == '__main__':
    main()
