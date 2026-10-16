#!/usr/bin/env python3
"""Replace only combined candidate's fresh64 predicate by an exact interval scan."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
PARENT = ROOT / 'selfhost/build/phase99/projection-branch-source01/changes.json'
PARENT_SOURCE_SHA = '782bdbeecebe9a628bc1be592d4ff6024f64cc65f8a1921237878e171e0fdb6a'


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase99') and not out.exists()
    parent = json.loads(PARENT.read_text())
    assert parent['candidate']['sha256'] == PARENT_SOURCE_SHA
    assert pin(parent['source']['file']) == parent['source']
    assert pin(parent['candidate']['file']) == parent['candidate']
    original = Path(parent['source']['file']).read_text(); candidate = original
    changes = list(parent['changes'])
    for change in changes:
        at = change['offset']; old = change['old']; new = change['new']
        assert candidate[at:at + len(old)] == old
        candidate = candidate[:at] + new + candidate[at + len(old):]
    assert hashlib.sha256(candidate.encode()).hexdigest() == PARENT_SOURCE_SHA
    before = candidate
    old = 'nt_choose(KTerm, nd_comb_fresh(body, args, env, n, 64),'
    new = 'nt_choose(KTerm, nbc_fresh(body, args, env, n),'
    assert candidate.count(old) == 1
    at = candidate.index(old); changes.append(dict(offset=at, old=old, new=new))
    candidate = candidate[:at] + new + candidate[at + len(old):]
    addition = '\n' + (HERE / 'interval-helper.bend').read_text()
    changes.append(dict(offset=len(candidate), old='', new=addition)); candidate += addition
    inverse = candidate
    for change in reversed(changes):
        at = change['offset']; assert inverse[at:at + len(change['new'])] == change['new']
        inverse = inverse[:at] + change['old'] + inverse[at + len(change['new']):]
    assert inverse == original
    out.mkdir(parents=True); (out / 'compiler.bend').write_text(candidate)
    recipe = dict(kind='phase99-projection-selector-interval-source', complete=True, targetsRun=False,
        source=parent['source'], parentCandidate=parent['candidate'], parentRecipe=pin(PARENT),
        method=pin(__file__), helper=pin(HERE / 'interval-helper.bend'), candidate=pin(out / 'compiler.bend'),
        changes=changes, inverseExact=True,
        parentPhysicalLineDelta=len(candidate.splitlines()) - len(before.splitlines()),
        parentByteDelta=len(candidate.encode()) - len(before.encode()),
        scope='Under unchanged n<4294967231 gate, replace 64 nc_occurs and nc_word scans by inclusive [nc_id(n+63),nc_id(n)] Var scan and exact first-binding/sentinel environment scan. Preserve Var-leaf behavior, all admission limits, expansion, runtime and projection changes.')
    (out / 'changes.json').write_text(json.dumps(recipe, indent=2) + '\n')
    print(json.dumps({k: recipe[k] for k in ['candidate', 'parentPhysicalLineDelta', 'parentByteDelta']}))


if __name__ == '__main__': main()
