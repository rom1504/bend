#!/usr/bin/env python3
"""Prepare a bounded aggregate-observer derivative of exact source04; no targets."""
import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
BASE = ROOT / 'selfhost/build/phase98/origin-guard-source01/compiler.bend'
PARENT = ROOT / 'selfhost/build/phase99/borrowed-calls-source04/changes.json'
PARENT_SHA = '9ca7e172757f67d4bc3fdb0ed6e924b96e5010480b8f79aa60592fd3a0cd33fd'
SOURCE04_SHA = 'c19e926eb7d8d41309c9ed8aa18960c484f3b17681507b57da5418ccfedd31ec'


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase99') and not out.exists()
    assert pin(PARENT)['sha256'] == PARENT_SHA
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

    def edit(old, new):
        nonlocal candidate
        assert old != new and candidate.count(old) == 1, old[:160]
        at = candidate.index(old); changes.append(dict(offset=at, old=old, new=new))
        candidate = candidate[:at] + new + candidate[at + len(old):]

    def definition(name):
        starts = list(re.finditer(r'^def ' + re.escape(name) + r'\(', candidate, re.M))
        assert len(starts) == 1, name
        start = starts[0].start(); return candidate[start:candidate.index('\n\n', start)]

    old = definition('nol_root_specs')
    edit(old, old.replace('u => nol_root_ctors(book, ty, dc(d)),',
        'u => nog_root_choice(book, ty, dc(d), Bool.not(db(d)), nol_root_ctors(book, ty, dc(d))),'))
    old = definition('nob_live_root')
    edit(old, old.replace('&& p88_string_eq(nm(actual), nm(param)),',
        '&& (p88_string_eq(nm(actual), nm(param)) || p98_tag_eq(noa_origin(actual), "OField")),'))
    old = definition('noa_reference')
    edit(old, old.replace('Bool.not(nc_foreign(d) || nc_native_def(d) || nb_contains(stack, name))',
        'Bool.not(nc_foreign(d) || nc_native_def(d)) && (Bool.not(nb_contains(stack, name)) || nog_virtual_roots(args, no_schema_roots(callee), 0))'))
    helpers = (HERE / 'helpers.bend').read_text()
    changes.append(dict(offset=len(candidate), old='', new='\n' + helpers))
    candidate += '\n' + helpers
    assert 'v => noa_below(kid(origin, 0), want), v => False{}' in candidate
    assert 'U32.is_lt(nt_count(String, stack), 8)' in definition('noa_reference')
    reverse = candidate
    for change in reversed(changes):
        at = change['offset']; assert reverse[at:at + len(change['new'])] == change['new']
        reverse = reverse[:at] + change['old'] + reverse[at + len(change['new']):]
    assert reverse == original
    assert pin(PARENT)['sha256'] == PARENT_SHA and pin(BASE) == parent['source']
    assert pin(parent['candidate']['file']) == parent['candidate']
    out.mkdir(parents=True); (out / 'compiler.bend').write_text(candidate)
    recipe = dict(kind='phase99-bounded-borrowed-projection-source', complete=True, targetsRun=False,
        source=pin(BASE), candidate=pin(out / 'compiler.bend'), parentCandidate=parent['candidate'],
        parentRecipe=pin(PARENT), method=pin(__file__), helpers=pin(HERE / 'helpers.bend'),
        changes=changes, inverseExact=True, source04ChangeCount=len(changes) - len(parent['changes']),
        source04PhysicalLineDelta=len(candidate.splitlines()) - len(source04.splitlines()),
        source04ByteDelta=len(candidate.encode()) - len(source04.encode()),
        physicalLineDelta=len(candidate.splitlines()) - len(original.splitlines()),
        byteDelta=len(candidate.encode()) - len(original.encode()),
        scope='At most four plain user ADT constructors, widths 0 or 2..8, applied fields opaque; typed descendant borrowed calls under any live schema root; certified virtual-root helper specialization retains depth8/fuel4096. No runtime, canonical, permission or source04 guard change.')
    (out / 'changes.json').write_text(json.dumps(recipe, indent=2) + '\n')
    print(json.dumps({key:recipe[key] for key in ['candidate', 'source04PhysicalLineDelta', 'source04ByteDelta']}))


if __name__ == '__main__': main()
