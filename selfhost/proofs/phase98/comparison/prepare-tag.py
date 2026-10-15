#!/usr/bin/env python3
"""Bind exact fused tag helper to production tg and accepted held comparison."""
import argparse
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
ACCEPTED = ROOT/'selfhost/build/phase98/held-simple-proof-check01/report.json'
HELD_SOURCE = ROOT/'selfhost/build/phase98/held-source02/compiler.bend'
HELPERS = ROOT/'selfhost/tools/performance/phase98/comparison/tag-helpers03.bend'
CONTROLS = ROOT/'selfhost/tools/performance/phase98/comparison/tag-controls03/receipt.json'


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def declaration(source, name):
    matches = list(re.finditer(r'(?m)^(?:@unsafe\n)?(?:type|def|law) ([\w.]+)\b', source))
    hits = [(i,m) for i,m in enumerate(matches) if m.group(1)==name]
    assert len(hits)==1
    i,m = hits[0]; end=matches[i+1].start()
    original = source[m.start():end]
    extracted = original.removeprefix('@unsafe\n')
    assert '@unsafe' not in extracted
    return dict(name=name, startByte=m.start(), endByte=end, original=original,
                extracted=extracted, removedUnsafe=original!=extracted)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); out=args.out.resolve()
    assert out.is_relative_to(ROOT) and not out.exists()
    accepted=json.loads(ACCEPTED.read_text())
    assert accepted['complete'] and accepted['independentlyChecked'] and not accepted['opaqueDefinitions']
    controls=json.loads(CONTROLS.read_text()); pins={p['file']:p for p in controls['inputs']}
    assert pin(HELD_SOURCE)==pins[str(HELD_SOURCE)] and pin(HELPERS)==pins[str(HELPERS)]
    frozen={}
    for row in accepted['sourceClosure']:
        assert pin(row['snapshot']['file'])==row['snapshot']
        name=Path(row['origin']['file']).name
        assert name not in frozen
        frozen[name]=Path(row['snapshot']['file']).read_bytes()
    assert set(frozen)=={'held-simple.bend','production.bend','candidate.bend','baseline.bend','reference.bend'}
    source=HELD_SOURCE.read_text()
    definitions=[declaration(source,name) for name in ['KTerm','tg']]
    helpers=HELPERS.read_text(); assert '@unsafe' not in helpers and 'import ' not in helpers
    old_candidate=frozen['candidate.bend'].decode()
    assert old_candidate.startswith('import Base\n\n')
    candidate='import Base\n\n'+definitions[0]['extracted']+old_candidate.removeprefix('import Base\n\n')+definitions[1]['extracted']+helpers
    out.mkdir(parents=True)
    for name,data in frozen.items(): (out/name).write_bytes(data)
    (out/'candidate.bend').write_text(candidate)
    for name in ['tag.bend','prepare-tag.py']: (out/name).write_bytes((HERE/name).read_bytes())
    manifest=dict(kind='phase98-exact-tag-comparison-proof-source',targetsRun=False,
                  acceptedComparison=pin(ACCEPTED),comparisonSourceClosure=accepted['sourceClosure'],
                  heldSource=pin(HELD_SOURCE),helpers=pin(HELPERS),controlReceipt=pin(CONTROLS),method=pin(__file__),
                  definitions=definitions,comparisonProofBytesUnchanged=True,comparisonImplementationBytesUnchanged=True,
                  outputs=[pin(p) for p in sorted(out.iterdir())],entry=str(out/'tag.bend'),
                  publicLaws=['tag_comparison_preserves'],supportLemmas=['tag_read_matches_projection'],
                  inheritedLaws=accepted['lawNames'],
                  transformation='Exact KTerm and tg declarations from actual held compiler; only leading @unsafe removed from tg. Exact tag helper bytes appended to unchanged accepted comparison implementation. Existing proof/reference bytes unchanged.',
                  boundary='Universal safe Bend Bool result. No proof of generated C lifetime, retained-root duration or unsafe compiler callers.')
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(json.dumps(dict(out=str(out),entry=manifest['entry'],targetsRun=False)))


if __name__=='__main__': main()
