#!/usr/bin/env python3
"""Prepare one bounded saturated-selector derivative of source04; no targets."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
BASE = ROOT / 'selfhost/build/phase98/origin-guard-source01/compiler.bend'
PARENT = ROOT / 'selfhost/build/phase99/borrowed-calls-source04/changes.json'
SOURCE04_SHA = 'c19e926eb7d8d41309c9ed8aa18960c484f3b17681507b57da5418ccfedd31ec'


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase99') and not out.exists()
    parent = json.loads(PARENT.read_text())
    assert pin(BASE) == parent['source']
    assert pin(parent['candidate']['file']) == parent['candidate']
    assert parent['candidate']['sha256'] == SOURCE04_SHA
    original = BASE.read_text(); candidate = original; changes = list(parent['changes'])
    for change in changes:
        at = change['offset']; old, new = change['old'], change['new']
        assert candidate[at:at + len(old)] == old
        candidate = candidate[:at] + new + candidate[at + len(old):]
    assert hashlib.sha256(candidate.encode()).hexdigest() == SOURCE04_SHA
    source04 = candidate
    old = 'u => nc_lower_to(book, nc_sequence(nt_choose(String, nf_scheduler(target), v => "NCall", v => "NFCall"), nt_choose(String, nf_scheduler(target), v => nd_name(nc_ref_name(book, nm(head))), v => nm(head)), args, Nil{}, n), env, U32.add(n, count), target),'
    new = 'u => nbc_saturated(book, head, args, env, n, target, count),'
    assert candidate.count(old) == 1
    at = candidate.index(old); changes.append(dict(offset=at, old=old, new=new))
    candidate = candidate[:at] + new + candidate[at + len(old):]
    helpers = '\n' + (HERE / 'helpers-v2.bend').read_text()
    changes.append(dict(offset=len(candidate), old='', new=helpers)); candidate += helpers
    inverse = candidate
    for change in reversed(changes):
        at = change['offset']; assert inverse[at:at + len(change['new'])] == change['new']
        inverse = inverse[:at] + change['old'] + inverse[at + len(change['new']):]
    assert inverse == original
    out.mkdir(parents=True); (out / 'compiler.bend').write_text(candidate)
    recipe = dict(kind='phase99-bounded-saturated-selector-source', complete=True, targetsRun=False,
        source=pin(BASE), parentCandidate=parent['candidate'], parentRecipe=pin(PARENT),
        candidate=pin(out / 'compiler.bend'), method=pin(__file__), helper=pin(HERE / 'helpers-v2.bend'),
        changes=changes, inverseExact=True,
        source04PhysicalLineDelta=len(candidate.splitlines()) - len(source04.splitlines()),
        source04ByteDelta=len(candidate.encode()) - len(source04.encode()),
        scope='Ordinary saturated Def with 1..4 actuals, at least one literal Lam; <=32-node closed App/Var/Lam/nullary-Mat/Ctr/Efq body with a match; each literal formal used at most once per exclusive matcher arm; 64 collision-checked fresh IDs. At most 32 callee nodes may duplicate a literal body across exclusive arms. Other actuals remain outer ordered lets; every refusal uses exact old call lowering. No name specialization, runtime, permission, canonical or source04 guard change.')
    (out / 'changes.json').write_text(json.dumps(recipe, indent=2) + '\n')
    print(json.dumps({k: recipe[k] for k in ['candidate', 'source04PhysicalLineDelta', 'source04ByteDelta']}))


if __name__ == '__main__': main()
