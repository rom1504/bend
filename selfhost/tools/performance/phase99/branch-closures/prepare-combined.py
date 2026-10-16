#!/usr/bin/env python3
"""Combine the exact projection01 and selector02 deltas; source/data only."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
PROJECTION = ROOT / 'selfhost/build/phase99/borrowed-projections-source01/changes.json'
BRANCH = ROOT / 'selfhost/build/phase99/branch-closures-source02/changes.json'
BASELINE = ROOT / 'selfhost/build/phase99/borrowed-calls-source04/changes.json'


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def replay(recipe):
    assert pin(recipe['source']['file']) == recipe['source']
    value = Path(recipe['source']['file']).read_text()
    for change in recipe['changes']:
        at = change['offset']; old = change['old']; new = change['new']
        assert value[at:at + len(old)] == old
        value = value[:at] + new + value[at + len(old):]
    assert pin(recipe['candidate']['file']) == recipe['candidate']
    assert hashlib.sha256(value.encode()).hexdigest() == recipe['candidate']['sha256']
    return value


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase99') and not out.exists()
    baseline, projection, branch = [json.loads(p.read_text()) for p in [BASELINE, PROJECTION, BRANCH]]
    assert baseline['candidate']['sha256'] == 'c19e926eb7d8d41309c9ed8aa18960c484f3b17681507b57da5418ccfedd31ec'
    assert branch['candidate']['sha256'] == 'be01c872a55b7eb024894ea013817c4f4eec9423a1ceda398ba44519bb68082c'
    assert projection['parentCandidate'] == baseline['candidate'] == branch['parentCandidate']
    source04 = replay(baseline); candidate = replay(projection); replay(branch)
    parent_count = len(baseline['changes'])
    assert branch['changes'][:parent_count] == baseline['changes']
    additions = branch['changes'][parent_count:]; assert len(additions) == 2
    changes = list(projection['changes'])
    for change in additions:
        old, new = change['old'], change['new']
        assert old == '' or candidate.count(old) == 1
        at = len(candidate) if old == '' else candidate.index(old)
        changes.append(dict(offset=at, old=old, new=new))
        candidate = candidate[:at] + new + candidate[at + len(old):]
    inverse = candidate
    for change in reversed(changes):
        at = change['offset']; assert inverse[at:at + len(change['new'])] == change['new']
        inverse = inverse[:at] + change['old'] + inverse[at + len(change['new']):]
    assert hashlib.sha256(inverse.encode()).hexdigest() == baseline['source']['sha256']
    out.mkdir(parents=True); (out / 'compiler.bend').write_text(candidate)
    recipe = dict(kind='phase99-projection-selector-combined-source', complete=True, targetsRun=False,
        source=baseline['source'], parentCandidate=baseline['candidate'],
        projectionCandidate=projection['candidate'], branchCandidate=branch['candidate'],
        projectionRecipe=pin(PROJECTION), branchRecipe=pin(BRANCH), baselineRecipe=pin(BASELINE),
        method=pin(__file__), candidate=pin(out / 'compiler.bend'), changes=changes, inverseExact=True,
        source04PhysicalLineDelta=len(candidate.splitlines()) - len(source04.splitlines()),
        source04ByteDelta=len(candidate.encode()) - len(source04.encode()),
        scope='Exact disjoint projection01 and selector02 changes atop source04. No combined correctness, timing or native-image claim is made by preparation.')
    (out / 'changes.json').write_text(json.dumps(recipe, indent=2) + '\n')
    print(json.dumps({k: recipe[k] for k in ['candidate', 'source04PhysicalLineDelta', 'source04ByteDelta']}))


if __name__ == '__main__': main()
