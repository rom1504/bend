#!/usr/bin/env python3
"""Compose exact source deltas, retaining the complete inverse to Phase98."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT/'selfhost/tools/performance/phase100'))
import run as R


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--parent', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--append', action='store_true')
    p.add_argument('--branch', action='store_true')
    a = p.parse_args(); out = a.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    parent = R.read(a.parent); assert parent['complete']
    for item in (parent['source'], parent['candidate']): R.verify(item)
    source = Path(parent['candidate']['file']).read_text(); additions = []; inputs = []
    if a.branch:
        path = ROOT/'selfhost/build/phase99/branch-closures-source02/changes.json'
        branch = R.read(path); inputs += [R.pin(path), branch['candidate'], branch['helper']]
        assert branch['candidate']['sha256'] == 'be01c872a55b7eb024894ea013817c4f4eec9423a1ceda398ba44519bb68082c'
        for item in inputs: R.verify(item)
        edits = branch['changes'][-2:]
        assert edits[0]['new'] == 'u => nbc_saturated(book, head, args, env, n, target, count),'
        assert edits[1]['old'] == '' and edits[1]['new'] == '\n'+Path(branch['helper']['file']).read_text()
        for edit in edits:
            old, new = edit['old'], edit['new']; assert not old or source.count(old) == 1
            at = source.index(old) if old else len(source)
            additions.append(dict(offset=at, old=old, new=new))
            source = source[:at]+new+source[at+len(old):]
    if a.append:
        path = Path(__file__).with_name('text')/'integrate.py'
        module = R.module('phase102_append_integration', path)
        inputs += [R.pin(path), R.pin(path.with_name('append.bend'))]
        source, changes = module.patch(source, equal='p88_string_eq'); additions += changes
    assert additions
    changes = parent['changes'] + additions
    reverse = source
    for edit in reversed(changes):
        at, old, new = edit['offset'], edit['old'], edit['new']
        assert reverse[at:at+len(new)] == new
        reverse = reverse[:at]+old+reverse[at+len(new):]
    assert reverse == Path(parent['source']['file']).read_text()
    target = out/'compiler.bend'; target.write_text(source)
    report = dict(complete=True, targetsRun=False, releaseQualified=False, method=R.pin(__file__),
        source=parent['source'], parentCandidate=parent['candidate'], parentRecipe=R.pin(a.parent),
        candidate=R.pin(target), append=a.append, branch=a.branch, changes=changes, inputs=inputs,
        inverseExact=True, physicalLineDelta=len(source.splitlines())-len(reverse.splitlines()),
        scope='Exact combined Bend source; correctness, performance and release gates remain separate.')
    R.save(out/'changes.json', report)
    print(R.json.dumps(dict(candidate=report['candidate'], physicalLineDelta=report['physicalLineDelta'])))


if __name__ == '__main__': main()
