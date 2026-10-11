#!/usr/bin/env python3
"""Derive additive raw controls and the unchanged-resource plan factory."""
import ast
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]


def pin(p):
    p = Path(p).resolve(strict=True)
    b = p.read_bytes()
    return dict(file=str(p), sha256=hashlib.sha256(b).hexdigest(), bytes=len(b))


def derive(parent, destination, edits, scope, dependencies=()):
    text = parent.read_text()
    for old, new in edits:
        assert text.count(old) == 1, (str(parent), old)
        text = text.replace(old, new)
    if destination.suffix == '.py':
        ast.parse(text)
    with destination.open('x') as f:
        f.write(text)
    record = dict(kind='phase69-custom-raw-derivation', producer=pin(__file__),
                  parent=pin(parent), output=pin(destination), dependencies=[pin(x) for x in dependencies],
                  edits=[dict(before=x, after=y, count=1) for x,y in edits],
                  dataOnly=True, targetsExecuted=False, scope=scope)
    with destination.with_suffix('.derivation.json').open('x') as f:
        json.dump(record, f, indent=2)
        f.write('\n')
    return destination


extension = HERE/'raw-extension-v1.js.txt'
parent = ROOT/'selfhost/tools/performance/phase68/controls/raw-controls-v7.mjs'
runner = derive(parent, HERE/'raw-controls-custom-v1.mjs', [
    ('const [recipeArg,baselineArg,candidateArg,outArg]=process.argv.slice(2);',
     'const [recipeArg,baselineArg,candidateArg,outArg,casesArg]=process.argv.slice(2);'),
    ("const root=path.resolve(import.meta.dirname,'../../../../..');", 'const root='+json.dumps(str(ROOT))+';'),
    ("const report={kind:'phase68-native-raw-controls-v6',complete:false,pass:false,inputs,rows:[]};",
     "const customPlan=JSON.parse(fs.readFileSync(casesArg,'utf8'));\nassert.equal(customPlan.kind,'phase69-custom-raw-cases');\ninputs.push(pin(casesArg),...customPlan.modules.map(x=>pin(x.file)));\nconst report={kind:'phase69-native-raw-custom-v1',complete:false,pass:false,inputs,rows:[]};"),
    (' inputs.forEach(x=>assert.deepEqual(pin(x.file),x));', extension.read_text()+'\n inputs.forEach(x=>assert.deepEqual(pin(x.file),x));'),
], 'Unchanged inherited twelve observations plus explicit module-driven raw cases; both image roles, retained C, same O1/threads1,4/runtime recipe. Named error equality and nonempty/no-C rejection are separate. Explicit reviewed per-role expectations are recorded as behavior changes; no generic baseline-failure exemption.', [extension])
parent = ROOT/'selfhost/build/phase69/methods01/prepare-raw.py'
derive(parent, HERE/'prepare-custom-raw.py', [
    ('    a = p.parse_args()', '''    p.add_argument('--case-module', type=Path, action='append', required=True)
    p.add_argument('--expected-added-cases', type=int, required=True)
    a = p.parse_args()
    assert 0 < a.expected_added_cases <= 100'''),
    ("controller = ROOT / 'selfhost/tools/performance/phase68/controls/raw-controls-v7.mjs'",
     "controller = ROOT / 'selfhost/tools/performance/phase69/methods/raw-controls-custom-v1.mjs'"),
    ("    assert not out.exists(); out.mkdir(parents=True)", '''    assert not out.exists(); out.mkdir(parents=True)
    modules = [pin(path) for path in a.case_module]
    assert len({x['file'] for x in modules}) == len(modules)
    cases_file = out/'cases.json'
    cases_file.write_text(json.dumps(dict(kind='phase69-custom-raw-cases', modules=modules,
        expectedAddedCases=a.expected_added_cases), indent=2)+'\\n')
    inputs += [*modules, pin(cases_file), pin(controller.with_suffix('.derivation.json')),
               pin(Path(__file__).with_suffix('.derivation.json'))]'''),
    ("str(out/'execution')]", "str(out/'execution'),str(cases_file)]"),
    ("kind='phase68-raw-native-control-plan'", "kind='phase69-custom-raw-native-control-plan'"),
    ("runtime=runtime,controller=pin(controller),command=command", "runtime=runtime,controller=pin(controller),customCases=pin(cases_file),expectedAddedCases=a.expected_added_cases,command=command"),
], 'Unchanged checked-image/runtime/native-recipe checking and180s/2GiB/4GiB guard, plus pinned custom modules and exact added-case count. Target execution remains root-only.', [runner, runner.with_suffix('.derivation.json')])
print(json.dumps(dict(runner=pin(runner), preparer=pin(HERE/'prepare-custom-raw.py'), targetsExecuted=False)))
