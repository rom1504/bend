#!/usr/bin/env python3
"""Retain pre-composition dependency cost in an exact isolated Bend recipe."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--parent', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    parent = json.loads(args.parent.read_text())
    assert parent['complete'] and parent['inverseExact']
    for item in (parent['source'], parent['candidate']):
        assert pin(item['file']) == item
    source = Path(parent['candidate']['file']).read_text()
    old = '            u => NF_Worker{name, params, newCode, newDeps, shape}, u => old)'
    new = ('            # Retain the original dependency horizon after eliminating wrappers.\n'
           '            # This is conservative cost metadata; every actual new call stays present.\n'
           '            u => NF_Worker{name, params, newCode, List.append(&2, String, deps, newDeps), shape}, u => old)')
    assert source.count(old) == 1
    offset = source.index(old)
    added = [dict(offset=offset, old=old, new=new)]
    candidate = source[:offset] + new + source[offset + len(old):]
    changes = parent['changes'] + added
    inverse = candidate
    for edit in reversed(changes):
        at = edit['offset']
        assert inverse[at:at + len(edit['new'])] == edit['new']
        inverse = inverse[:at] + edit['old'] + inverse[at + len(edit['new']):]
    assert inverse == Path(parent['source']['file']).read_text()
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase102')
    out.mkdir(parents=True, exist_ok=False)
    dest = out / 'compiler.bend'
    dest.write_text(candidate)
    report = dict(complete=True, targetsRun=False, releaseQualified=False,
        method=pin(__file__), parentRecipe=pin(args.parent), parentCandidate=parent['candidate'],
        source=parent['source'], candidate=pin(dest), changes=changes, addedChanges=added,
        inverseExact=True, physicalLineDelta=len(candidate.splitlines()) - len(source.splitlines()),
        scope='Projection replacement keeps old plus new conservative worker dependencies. '
              'All actual new edges remain; admitted worker bodies, ownership, public ABI and '
              'projection certificate are unchanged. The depth-limited forced-inline policy '
              'cannot become more permissive than its parent. No name-specific selection. '
              'Actual checked emission, timing and native gates remain separate.')
    (out / 'changes.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({key: report[key] for key in ('candidate', 'physicalLineDelta')}))


if __name__ == '__main__':
    main()
