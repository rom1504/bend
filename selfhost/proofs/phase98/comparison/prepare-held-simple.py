#!/usr/bin/env python3
"""Prepare exact no-carrier held comparison refactor; no targets."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def public_contract(text):
    return re.search(r'law held_comparison_preserves:\n.*?(?=\ndef held_comparison_preserves)', text, re.S).group(0)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--candidate', type=Path, required=True)
    parser.add_argument('--receipt', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(ROOT) and not out.exists()
    # Reuse the frozen byte extractor without changing its implementation.
    spec = importlib.util.spec_from_file_location('exact', HERE/'prepare-held-exact.py')
    module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
    receipt = json.loads(args.receipt.read_text())
    assert pin(module.BASE)['sha256'] == receipt['source']['sha256']
    assert pin(args.candidate)['sha256'] == receipt['candidate']['sha256']
    baseline, candidate = module.BASE.read_text(), args.candidate.read_text()
    replay = baseline
    for change in receipt['changes']:
        assert replay.count(change['old']) == 1
        replay = replay.replace(change['old'], change['new'], 1)
    assert replay == candidate
    production = module.extract(baseline, ['p88_string_eq_go', 'p88_string_eq'])
    changed = module.extract(candidate, ['p88_string_eq_go', 'p98_eq_finish', 'p88_string_eq'])
    assert production[0]['exactBody'] == changed[0]['exactBody']
    assert 'P98EqHeld' not in candidate and 'p98_eq_observe' not in candidate
    original_contract = public_contract((HERE/'held-exact.bend').read_text())
    assert original_contract == public_contract((HERE/'held-simple.bend').read_text())
    out.mkdir(parents=True)
    for name, rows in [('production.bend', production), ('candidate.bend', changed)]:
        (out/name).write_text('import Base\n\n'+''.join(row['exactBody'] for row in rows))
    copied = ['reference.bend', 'baseline.bend', 'held-simple.bend', 'prepare-held-simple.py', 'prepare-held-exact.py']
    for name in copied: (out/name).write_bytes((HERE/name).read_bytes())
    manifest = dict(kind='phase98-exact-no-carrier-held-proof-source', targetsRun=False,
                    source=pin(module.BASE), candidate=pin(args.candidate), receipt=pin(args.receipt), method=pin(__file__),
                    extractor=pin(HERE/'prepare-held-exact.py'), productionDefinitions=production, candidateDefinitions=changed,
                    forwardReplayExact=True, walkerBodyUnchanged=True, publicContractUnchanged=original_contract,
                    originalProof=pin(HERE/'held-exact.bend'), revisedProof=pin(HERE/'held-simple.bend'),
                    retiredLaw=dict(name='held_observation_complete', reason='Its carrier type and complete-observation helper were removed, so that helper-result theorem has no revised subject. The public Bool contract is unchanged.'),
                    outputs=[pin(out/name) for name in ['production.bend','candidate.bend',*copied]],
                    entry=str(out/'held-simple.bend'),
                    boundary='Exact safe Bool equality; no C lifetime theorem or retained helper-result claim.')
    (out/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    print(json.dumps(dict(out=str(out), entry=manifest['entry'], targetsRun=False)))


if __name__ == '__main__':
    main()
