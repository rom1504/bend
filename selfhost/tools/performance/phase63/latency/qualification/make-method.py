#!/usr/bin/env python3
"""Derive Phase63 final qualification methods; never execute compiler targets."""
import argparse
import ast
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
RAW = ROOT/'selfhost/build/phase63'
PARENT = ROOT/'selfhost/build/phase61/methods-frame02/methods.json'
PARENT_SHA = 'e555167c7a1b62e0f98c89a655073d46b6d67c62adc766b6a66b980e7dba91da'
FINAL = ROOT/'selfhost/tools/performance/phase61/validation/final-plan-frame02.py'
FINAL_SHA = '8338781e4eb6bf45c857e4c775bbe953aee1e00535cfbd5a858b528e715e6a57'
BOOTSTRAP = Path(__file__).resolve().parents[1]/'prepare-bootstrap.py'
OMIT = {'bootstrap/prepare-candidate.py', 'qualification/final-orchestration-v2.py'}


def identity(file):
    file = Path(file).resolve(strict=True)
    return dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    out = a.out.resolve()
    assert out.parent == RAW.resolve() and not out.exists()
    assert identity(PARENT)['sha256'] == PARENT_SHA
    parent = json.loads(PARENT.read_text())
    assert parent['complete'] and not parent['targetsExecuted']
    inputs = [identity(__file__), identity(PARENT)]
    rows = []
    assert identity(FINAL)['sha256'] == FINAL_SHA
    bootstrap = identity(BOOTSTRAP)
    inputs += [identity(FINAL), bootstrap]
    selected = [*parent['rows'], dict(relative='qualification/final-plan.py', output=identity(FINAL))]
    for original in selected:
        source = Path(original['output']['file'])
        assert identity(source) == original['output']
        relative = original['relative']
        if relative in OMIT:
            continue
        text = source.read_text()
        edits = []

        def change(old, new):
            nonlocal text
            assert old in text, (relative, old)
            text = text.replace(old, new)
            edits.append(dict(old=old, new=new))

        if 'selfhost/build/phase61' in text:
            change('selfhost/build/phase61', 'selfhost/build/phase63')
        for old, new in [('inside Phase61', 'inside Phase63'), ('stay in Phase61', 'stay in Phase63')]:
            if old in text:
                change(old, new)
        if relative in {'bootstrap/setup.mjs', 'qualification/checked-image.mjs'}:
            change('-frame[12]\\.json$', '-frame[123]\\.json$')
            if relative == 'bootstrap/setup.mjs':
                change("  copy(path.join(snapshot,'src/compiler.json'),'src/compiler.json');",
                       "  const graphHelper=path.join(snapshot,'tools/base-cache-graph.mjs');\n"
                       "  if(fs.existsSync(graphHelper))copy(graphHelper,'tools/base-cache-graph.mjs');\n"
                       "  copy(path.join(snapshot,'src/compiler.json'),'src/compiler.json');")
            else:
                change(" copy(path.join(attempt.snapshot.root,'src/compiler.json'),'src/compiler.json');",
                       " const graphHelper=path.join(attempt.snapshot.root,'tools/base-cache-graph.mjs');\n"
                       " if(fs.existsSync(graphHelper))copy(graphHelper,'tools/base-cache-graph.mjs');\n"
                       " copy(path.join(attempt.snapshot.root,'src/compiler.json'),'src/compiler.json');")
        if relative == 'qualification/plan.py':
            change("assert not a.plan.exists()", "assert a.plan.resolve().is_relative_to(ROOT/'selfhost/build/phase63')and not a.plan.exists()")
        if relative == 'qualification/b2-plan.py':
            change("assert not a.plan_file.exists()", "assert a.plan_file.resolve().is_relative_to(root/'selfhost/build/phase63') and not a.plan_file.exists()")
        if relative == 'bootstrap/reproduce.mjs':
            change("api.jd_reach_selected(context,selected,rootList)", "api.jd_plan_selected(context,selected,rootList)")
            change("api.jd_reach_error(reachable)", "api.jd_plan_error(reachable)")
            change("api.jd_reach_defs(reachable)", "api.jd_plan_defs(reachable)")
            change("api.jd_library_selected(context,selected)", "api.jd_plan_library(reachable)")
        if relative == 'qualification/final-plan.py':
            change("BOOTSTRAP_PRODUCER=TOOLS/'phase61/validation/prepare-candidate-v5.py'",
                   "BOOTSTRAP_PRODUCER=TOOLS/'phase63/latency/prepare-bootstrap.py'")
            change("BOOTSTRAP_SHA='1e72fcf80a5386c9270eff0d6db4b661427283a11fe8cba906f41093f35a0bc6'",
                   'BOOTSTRAP_SHA='+repr(bootstrap['sha256']))
            change("PARENT=Path(__file__).with_name('final-plan-frame01.py')",
                   "PARENT=TOOLS/'phase61/validation/final-plan-frame01.py'")
            change("FACTORY=Path(__file__).with_name('prepare-methods-frame02.py')",
                   'FACTORY=Path('+repr(str(Path(__file__).resolve()))+')')
            change("FACTORY_SHA='62dc13dc6ef8ec6b0ae056e4223593f3f14c84c31f3eaa6a050dcb1cb07f8e7a'",
                   'FACTORY_SHA='+repr(identity(__file__)['sha256']))
            change("method['kind']=='phase61-explicit-export-validation-methods'",
                   "method['kind']=='phase63-final-qualification-methods'")
            change('installed7/protected103/closed raw', 'installed7/protected110/closed raw')
        replay = source.read_text()
        for edit in edits:
            assert edit['old'] in replay
            replay = replay.replace(edit['old'], edit['new'])
        assert replay == text
        if relative.endswith('.py'):
            ast.parse(text, filename=relative)
        inputs.append(identity(source))
        rows.append(dict(relative=relative, parent=identity(source), edits=edits, text=text))
    assert len(rows) == 17
    for row in inputs:
        assert identity(row['file']) == row
    out.mkdir(parents=True)
    for row in rows:
        dest = out/row['relative']
        dest.parent.mkdir(parents=True, exist_ok=True)
        with dest.open('x') as stream:
            stream.write(row.pop('text'))
        row['output'] = identity(dest)
    result = dict(kind='phase63-final-qualification-methods', complete=True, targetsExecuted=False,
        producer=identity(__file__), parent=identity(PARENT), baseline=parent['baseline'],
        inputs=inputs, rows=rows, omitted=sorted(OMIT),
        scope='Identical semantic/value/byte oracles. New Phase63 output boundary, private optional '
        'snapshot graph-helper staging, frame3 filename admission with unchanged decoded versions4/6, '
        'explicit plan output containment, and unsplit reproduction through the actual JDPlan API. '
        'Actual checked exports remain admission/reference-bound; '
        'no current source or compiler image is bound by this factory. Separate Phase63 B2 producer '
        'and a recorded final-plan-frame02 derivative replace omitted obsolete planners.')
    for file in [out/'methods.json', out/'qualification/b2-methods-derivation.json']:
        with file.open('x') as stream:
            stream.write(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(methods=identity(out/'methods.json'), files=len(rows), targetsExecuted=False)))


if __name__ == '__main__':
    main()
