#!/usr/bin/env python3
"""Offline-only current-release JS23/C12 continuity plan; executes no compiler."""
import argparse, hashlib, json, re, shutil, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
P90 = ROOT/'selfhost/build/phase90'
NODE = Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node')
ap = argparse.ArgumentParser(description=__doc__)
ap.add_argument('out', type=Path)
a = ap.parse_args()
out = a.out.resolve()
assert out.is_relative_to(ROOT/'selfhost/build/phase91') and not out.exists()
inputs = {}

def pin(value):
    f = Path(value).resolve(strict=True)
    b = f.read_bytes()
    return dict(file=str(f), sha256=hashlib.sha256(b).hexdigest(), bytes=len(b))

def bind(value):
    if isinstance(value, (str, Path)):
        value = pin(value)
    actual = pin(value.get('file', value.get('path')))
    assert actual['sha256'] == value['sha256'], actual['file']
    if 'bytes' in value:
        assert actual['bytes'] == value['bytes'], actual['file']
    assert inputs.setdefault(actual['file'], actual) == actual
    return actual

def read(value):
    return json.loads(Path(bind(value)['file']).read_text())

bind(__file__); method = bind(HERE/'worker.mjs'); node = bind(NODE)
guard = bind(ROOT/'selfhost/tools/performance/phase86/guard.py')
release_pin = bind(ROOT/'selfhost/dist/release.json'); release = read(release_pin)
assert release['kind'] == 'bend-default-selfhost-release' and release['artifact'] == 'self-emitted-b2'
for item in release['files']:
    bind(dict(item, file=str(ROOT/'selfhost'/item['path'])))
pins_pin = bind(P90/'compiler07-b2/image-pins.json'); pins = read(pins_pin)
assert pins['kind'] == 'phase56-direct-image-pins'
for key in ['producer', 'plan', 'attempt', 'emission', 'comparison', 'source', 'b1', 'b2', 'runtime', 'rootsReference', 'admission']:
    bind(pins[key])
assert pins['b2']['sha256'] == release['lineage']['selfEmittedSha256'] == '284f6e9b88614c4cbd60812a7641fb03d9b9c49892c9bb0d692b1b2c31b5bd30'
assert pins['b1']['sha256'] == release['lineage']['generatorSha256'] == '6bf8e0938565fc4a1b2152640ac83e11e0538fe080a1ec6ac8b89ec6c5958379'
attempt = read(pins['attempt']); assert attempt['checked'] and attempt['artifactKind'] == 'derived-b1'
assert attempt['api']['sha256'] == pins['b1']['sha256']
assert bind(attempt['node']) == node
for item in attempt['snapshot']['sources']:
    bind(item['frozen'])
for item in attempt['artifacts']:
    bind(item)
validation = read(P90/'compiler07/validation-001/report.json')
assert validation['complete'] and validation['pass'] and validation['strictExact']
emission, comparison = read(pins['emission']), read(pins['comparison'])
assert emission['complete'] and emission['pass'] and emission['module']['sha256'] == pins['b2']['sha256']
assert comparison['complete'] and comparison['pass'] and comparison['observations'] == 8
project = Path(attempt['snapshot']['root'])
host = dict(project=str(project), driver=bind(project/'tools/typed-driver.mjs'),
            runtime=bind(attempt['runtime']), base=bind(attempt['base']), directRuntime=bind(pins['runtime']),
            nativeRuntime=bind(project/'src/runtime/native/runtime.c'),
            nativeTemplate=bind(project/'src/runtime/native/runtime-template.json'))

js_receipt = bind(ROOT/'selfhost/build/phase82/js-continuity04/report.json')
js = read(js_receipt); assert js['complete'] and js['pass'] and len(js['rows']) == 23
assert host['directRuntime']['sha256'] == js['image']['directRuntime']['sha256']
assert host['runtime']['sha256'] == js['image']['runtime']['sha256']
assert host['base']['sha256'] == js['image']['base']['sha256']
js_cases = []
for index, row in enumerate(js['rows']):
    assert row['exact'] and row['observation']['checked'] and row['observation']['status'] == 'ok'
    for f in row['observation']['files']:
        old = next(p for p in js['inputs'] if p['file'] == f)
        bind(old)
    js_cases.append(dict(name=f'js-{index:02d}', source=bind(row['source']), oracle=bind(row['reference'])))
timing_js = bind(ROOT/'implementation/phase66/evidence/runtime-selected07-full.json')
assert read(timing_js)['pass']

c_plan_pin = bind(ROOT/'selfhost/build/phase82/compiler04-C-identity12/plan.json')
c_plan = read(c_plan_pin); assert c_plan['expectedCases'] == 12 and len(c_plan['cases']) == 12
timing_c = bind(ROOT/'implementation/phase78/runtime.json'); assert read(timing_c)['complete']
runtime_plan_pin = bind(ROOT/'selfhost/tools/performance/phase90/regalloc/runtime-accessor-01/plan.json')
runtime_plan = read(runtime_plan_pin)
assert host['nativeRuntime']['sha256'] == runtime_plan['source']['sha256']
assert len(runtime_plan['edits']) == 2
c_cases = []; cc = None; cc_args = None
for name, case in c_plan['cases'].items():
    assert case['expected']['b1'] == case['expected']['b2']
    source, oracle = bind(case['input']), bind(case['expected']['b1'])
    for key in ['nativeOracleEvidence', 'acquisition', 'validatedExecutable', 'recipe']:
        bind(case[key])
    recipe = read(case['recipe'])
    if cc is None:
        cc = bind(recipe['clang']); cc_args = recipe['clangArgs']
    assert recipe['clang'] == cc['file'] and recipe['clangArgs'] == cc_args
    assert cc_args == ['-isystem', '/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/include/clang', '-std=c11', '-O3']
    joined = read(ROOT/f'selfhost/build/phase82/compiler04-C-identity12/runs/clean-identity-{name}-b2/report.json')
    assert joined['complete'] and joined['pass'] and joined['exactC']
    for item in joined['requestInputs']:
        bind(item)
    text = Path(oracle['file']).read_text(); fids = re.findall(r'^#define FID_ENTER (\d+)$', text, re.M)
    assert len(fids) == 1 and int(fids[0]) < 4096
    changed = text
    for edit in runtime_plan['edits']:
        assert changed.count(edit['before']) == 1
        changed = changed.replace(edit['before'], edit['after'], 1)
    c_cases.append(dict(name=name, source=source, oracle=oracle, fidEnter=int(fids[0]),
                        runtimeDerivativeSha256=hashlib.sha256(changed.encode()).hexdigest()))

# Prebind the actually observed O2 header closure, then stat.h's literal closure.
# The old C12 -O3/-std=c11 command may use fewer headers; every observed header is
# checked against this fixed superset, never admitted after target execution.
header_receipt = bind(P90/'runtime-cpp45/report.json'); old_headers = read(header_receipt)
assert old_headers['complete'] and old_headers['pass_']
headers = {}
for item in old_headers['inputs']:
    if item['file'].startswith(('/usr/include/', str(Path(cc_args[1]))+'/')):
        h = bind(item); headers[h['file']] = h
queue = [Path('/usr/include/x86_64-linux-gnu/sys/stat.h')]
while queue:
    f = queue.pop().resolve()
    if str(f) in headers:
        continue
    h = bind(f); headers[h['file']] = h
    for include in re.findall(r'^\s*#\s*include\s*[<"]([^>"]+)', f.read_text(), re.M):
        options = [f.parent/include, Path('/usr/include/x86_64-linux-gnu')/include, Path('/usr/include')/include]
        matches = [p for p in options if p.is_file()]; assert matches, (f, include)
        queue.append(matches[0])

assert len(js_cases) == 23 and len(c_cases) == 12
assert shutil.disk_usage(ROOT).free >= 64*1024**2, 'Need 64 MiB free for bounded outputs'
plan = dict(kind='phase91-current-release-js23-c12-continuity', version=1, targetExecuted=False,
            release=release_pin, imagePins=pins_pin, attempt=bind(pins['attempt']), host=host,
            roles={role:bind(pins[role]) for role in ['b1','b2']}, node=node, method=method,
            jsCases=js_cases, cCases=c_cases, jsHistoricalJoin=js_receipt, cHistoricalJoin=c_plan_pin,
            jsTiming=timing_js, cTiming=timing_c, runtimeChange=runtime_plan_pin,
            clang=cc, clangArgs=cc_args, headers=list(headers.values()), headerReceipt=header_receipt,
            cwd=str(ROOT), inputs=list(inputs.values()),
            scope='No program execution or fresh speed claim. Complete JS identity and complete optimized CPU C preprocessing identity on the actual timed JS23/C12 sources. B1 and genuine B2 are independent current-release roles.')
for item in list(inputs.values()):
    bind(item)
out.mkdir(parents=True)
(out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n')
commands = []
for role in ['b1','b2']:
    commands.append(dict(role=role,command=[sys.executable,'-B',guard['file'],'--out',str(out/(role+'-guard')),
        '--seconds','180','--rss-mib','2048','--available-mib','4096','--cpu','3','--',node['file'],
        '--stack-size=4096','--max-old-space-size=1024',method['file'],str(out/'plan.json'),role,str(out/role),'both']))
(out/'commands.json').write_text(json.dumps(dict(kind='phase91-root-serial-continuity-commands',commands=commands),indent=2)+'\n')
print(json.dumps(dict(complete=True,targetExecuted=False,plan=pin(out/'plan.json'),headers=len(headers),
                     jsSources=len(js_cases),cSources=len(c_cases),frozenInputs=len(inputs))))
