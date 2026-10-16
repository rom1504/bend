#!/usr/bin/env python3
"""Prepare bounded existing-observer forwarding in an isolated Bend compiler."""
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
    inputs = parser.add_mutually_exclusive_group(required=True)
    inputs.add_argument('--source', type=Path)
    inputs.add_argument('--parent', type=Path)
    parser.add_argument('--out', required=True, type=Path)
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase102') and not out.exists()
    parent = json.loads(args.parent.read_text()) if args.parent else None
    if parent:
        assert parent['complete'] and parent['inverseExact']
        for p in (parent['source'], parent['candidate']):
            assert pin(p['file']) == p
        args.source = Path(parent['candidate']['file'])
    source = args.source.read_text()
    name = 'def nf_plan_scoped('
    at = source.index(name)
    end = source.index('\n\n', at)
    old = source[at:end]
    anchor = '  nf_plan_workers('
    assert old.count(anchor) == 1
    new = old.replace(anchor, '  nfo_plan(book, nf_plan_workers(') + ')'
    helpers = (HERE / 'observer-forward-v2.bend').read_text()
    helpers = helpers.replace('String.eq(', 'p88_string_eq(')
    candidate = source[:at] + new + source[end:] + '\n' + helpers
    changes = [dict(offset=at, old=old, new=new),
               dict(offset=len(source) + len(new) - len(old), old='', new='\n' + helpers)]
    inverse = candidate
    for c in reversed(changes):
        assert inverse[c['offset']:c['offset'] + len(c['new'])] == c['new']
        inverse = inverse[:c['offset']] + c['old'] + inverse[c['offset'] + len(c['new']):]
    assert inverse == source
    if parent:
        for c in reversed(parent['changes']):
            assert inverse[c['offset']:c['offset'] + len(c['new'])] == c['new']
            inverse = inverse[:c['offset']] + c['old'] + inverse[c['offset'] + len(c['new']):]
        assert inverse == Path(parent['source']['file']).read_text()
    out.mkdir(parents=True)
    (out / 'compiler.bend').write_text(candidate)
    report = dict(complete=True, targetsRun=False, releaseQualified=False,
        method=pin(__file__), helpers=pin(HERE / 'observer-forward-v2.bend'),
        source=parent['source'] if parent else pin(args.source), candidate=pin(out / 'compiler.bend'),
        changes=(parent['changes'] if parent else []) + changes, addedChanges=changes,
        inverseExact=True, inverseToParentExact=True,
        physicalLineDelta=len(candidate.splitlines()) - len(source.splitlines()),
        byteDelta=len(candidate.encode()) - len(source.encode()),
        scope='Existing checked owning observer proof and private-name gates; '
              'only unready ordinary boxed workers may forward to an admitted adapter. '
              'Original scalar shared/unique policy is unchanged. Late cold-layout metadata '
              'for early routes is conservatively omitted in this prototype.')
    if parent:
        report.update(parentCandidate=parent['candidate'], parentRecipe=pin(args.parent))
    (out / 'changes.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({k:report[k] for k in ('candidate', 'physicalLineDelta', 'byteDelta')}))


if __name__ == '__main__':
    main()
