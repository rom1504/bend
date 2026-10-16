#!/usr/bin/env python3
"""Replay Phase98 -> source03, then add the all-trivial observer route. No targets."""
import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
BASE = ROOT / 'selfhost/build/phase98/origin-guard-source01/compiler.bend'
PARENT = ROOT / 'selfhost/build/phase99/borrowed-calls-source03/changes.json'
BASE_SHA = '2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051'
PARENT_SHA = 'ecf11951bfbfff22b5d0d73c8d37149faf52af1a7a930b408c2bbdaf97d0562c'
SOURCE03_SHA = '3a3d9c098fc8d091e0fde08f2b02a54e6fe96e5e0705ca8195144acb4cae5ccb'


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase99') and not out.exists()
    before = {'base': pin(BASE), 'parentRecipe': pin(PARENT),
              'helper': pin(HERE / 'static-helper.bend')}
    assert before['base']['sha256'] == BASE_SHA
    assert before['parentRecipe']['sha256'] == PARENT_SHA
    parent = json.loads(PARENT.read_text())
    assert parent['source'] == before['base'] and parent['inverseExact']
    assert pin(parent['candidate']['file']) == parent['candidate']
    assert parent['candidate']['sha256'] == SOURCE03_SHA
    original = BASE.read_text(); candidate = original
    changes = list(parent['changes'])
    for change in changes:
        at = change['offset']; old = change['old']; new = change['new']
        assert candidate[at:at + len(old)] == old
        candidate = candidate[:at] + new + candidate[at + len(old):]
    assert hashlib.sha256(candidate.encode()).hexdigest() == SOURCE03_SHA
    source03 = candidate

    def edit(old, new):
        nonlocal candidate
        assert old != new and candidate.count(old) == 1, old[:160]
        offset = candidate.index(old)
        changes.append(dict(old=old, new=new, offset=offset))
        candidate = candidate[:offset] + new + candidate[offset + len(old):]

    def definition(name, text):
        matches = list(re.finditer(r'^def ' + re.escape(name) + r'\(', text, re.M))
        assert len(matches) == 1, name
        start = matches[0].start(); return text[start:text.index('\n\n', start)]

    edit('# Scalar observers borrow only shared roots. Keep the existing owned worker\n'
         '# for unique inputs, including its tail loop, ownership and error checks.',
         '# Scalar observers borrow if any root is shared or every root is trivial.\n'
         '# Other inputs retain the owned worker, tail loop and ownership checks.')
    anchor = '# Module: src/back/native/observer-integration.bend:110\n@unsafe\ndef no_scalar_redirect('
    helper = (HERE / 'static-helper.bend').read_text()
    edit(anchor, helper + '\n' + anchor)
    old = '"if (" ++ no_shared_roots(params, roots, 0) ++ ") { return "'
    new = '"if ((" ++ no_shared_roots(params, roots, 0) ++ ") || (" ++ no_all_trivial_roots(params, roots, 0) ++ ")) { return "'
    edit(old, new)
    assert definition('no_shared_roots', candidate) == definition('no_shared_roots', source03)
    redirect = definition('no_scalar_redirect', candidate)
    assert redirect.replace(new, old, 1) == definition('no_scalar_redirect', source03)
    assert 'v => noa_below(kid(origin, 0), want), v => False{}' in candidate
    reverse = candidate
    for change in reversed(changes):
        at = change['offset']; assert reverse[at:at + len(change['new'])] == change['new']
        reverse = reverse[:at] + change['old'] + reverse[at + len(change['new']):]
    assert reverse == original
    assert pin(BASE) == before['base'] and pin(PARENT) == before['parentRecipe']
    assert pin(HERE / 'static-helper.bend') == before['helper']
    assert pin(parent['candidate']['file']) == parent['candidate']
    out.mkdir(parents=True); (out / 'compiler.bend').write_text(candidate)
    recipe = dict(kind='phase99-certified-borrowed-calls-all-trivial-source',
                  complete=True, targetsRun=False, method=pin(__file__),
                  helpers=before['helper'], parentRecipe=before['parentRecipe'],
                  source=before['base'], parentCandidate=parent['candidate'],
                  candidate=pin(out / 'compiler.bend'), changes=changes,
                  inverseExact=True, existingSharedPredicateExact=True,
                  originalRedirectExactExceptGuard=True,
                  source03ChangeCount=len(changes) - len(parent['changes']),
                  source03PhysicalLineDelta=len(candidate.splitlines()) - len(source03.splitlines()),
                  source03ByteDelta=len(candidate.encode()) - len(source03.encode()),
                  physicalLineDelta=len(candidate.splitlines()) - len(original.splitlines()),
                  byteDelta=len(candidate.encode()) - len(original.encode()),
                  scope='Existing ANY-shared route OR ALL schema roots term_triv; unique dynamic fallback, schemas, certificate admission, adapters, runtime and canonical files unchanged.')
    (out / 'changes.json').write_text(json.dumps(recipe, indent=2) + '\n')
    print(json.dumps({k: recipe[k] for k in ['candidate', 'source03PhysicalLineDelta', 'source03ByteDelta', 'physicalLineDelta', 'byteDelta']}))


if __name__ == '__main__':
    main()
