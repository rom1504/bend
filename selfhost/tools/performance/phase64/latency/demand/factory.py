#!/usr/bin/env python3
"""Prepare a private demand probe, or run its root-authorized serial workers."""
import argparse
import hashlib
import json
import shlex
import shutil
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
RAW = ROOT/'selfhost/build/phase64'
TOOLS = ROOT/'selfhost/tools/performance'
HELPER = RAW/'cache-artifact/demand-state09-helper.mjs'
HELPER_SHA = '5880cae7c7049991b7cda749b09663fa907e5d83302b75511350ef377dad83dc'
WORKER = Path(__file__).with_name('worker.mjs')


def pin(value):
    file = Path(value['file'] if isinstance(value, dict) else value).resolve(strict=True)
    row = dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())
    if isinstance(value, dict):
        assert row['sha256'] == value['sha256'], str(file)
    return row


def read(file):
    return json.loads(Path(pin(file)['file']).read_text())


def save(file, value):
    file.parent.mkdir(parents=True, exist_ok=True)
    file.write_text(json.dumps(value, indent=2)+'\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='mode', required=True)
    prepare = sub.add_parser('prepare')
    prepare.add_argument('preparation', type=Path)
    prepare.add_argument('out', type=Path)
    run = sub.add_parser('run')
    run.add_argument('plan', type=Path)
    run.add_argument('out', type=Path)
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(RAW.resolve()) and not out.exists()
    if args.mode == 'prepare':
        assert pin(HELPER)['sha256'] == HELPER_SHA
        receipt = read(args.preparation)
        assert receipt['complete'] and receipt['pass']
        config = read(receipt['config'])
        selected = next(row for row in receipt['preparations'] if row['observation']['role'] == 'baseline')
        observation = read(selected['result'])
        assert selected['success'] and observation == selected['observation'] and observation['complete'] and observation['pass']
        assert observation['image']['api']['sha256'] == 'e838cbab6e6543d1785da0474c50c1c33ab91e6806d2e6796cfcbeabf5b98003'
        inputs = [pin(__file__), pin(WORKER), pin(HELPER), pin(args.preparation), pin(receipt['config']),
                  pin(selected['result']), pin(config['node']), pin(TOOLS/'programs/support.py'),
                  pin(TOOLS/'phase63/latency/host-variants.py'), pin(TOOLS/'phase63/latency/host-variant-worker.mjs')]
        inputs += [pin(item) for item in observation['inputs']]
        original = Path(observation['project'])
        originals = [pin(item['after']) for item in observation['copies']] + [pin(item) for item in observation['verification']['cacheFiles']]
        assert len({item['file'] for item in originals}) == len(originals)
        cases = []
        for name in ['numeric-recurrence', 'lexer', 'test-map-set-ops']:
            case = next(item for item in config['cases'] if item['id'] == name)
            oracle = next(item for item in observation['outputs'] if item['id'] == name)
            assert oracle['oracle']['pass']
            inputs += [pin(case['source']), *[pin(item) for item in case['files']],
                       *[pin(item) for item in case['emissionInputs']], pin(oracle['output'])]
            cases.append(dict(id=name, source=case['source'], files=case['files'], emissionInputs=case['emissionInputs'], expected=oracle['output']))
        project = out/'proxy/project'
        copied, changes = [], []
        for item in originals:
            source = Path(item['file'])
            relative = source.relative_to(original)
            dest = project/relative
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, dest)
            assert pin(dest)['sha256'] == item['sha256']
            if str(relative) == 'tools/base-cache-graph.mjs':
                shutil.copyfile(HELPER, dest)
                changes.append(dict(relative=str(relative), before=item, after=pin(dest), replacement=pin(HELPER)))
            if str(relative) == 'tools/typed-driver.mjs':
                text = source.read_text()
                edits = []

                def change(old, new):
                    nonlocal text
                    assert text.count(old) == 1, old
                    text = text.replace(old, new)
                    edits.append(dict(old=old, new=new))

                change("import {encodeBaseGraph,decodeBaseGraph} from './base-cache-graph.mjs';",
                       "import {encodeBaseGraph,decodeBaseGraph,setDemandPhase} from './base-cache-graph.mjs';")
                change('export async function loadApi() {',
                       "const demandWrappedApis=new WeakSet();\nfunction demandWrapApi(api){\n"
                       "  if(demandWrappedApis.has(api))return;demandWrappedApis.add(api);\n"
                       "  for(const [name,fn] of Object.entries(api))if(typeof fn==='function'){\n"
                       "    const wrapped=function(...args){const previous=setDemandPhase('api:'+name);try{return Reflect.apply(fn,this,args);}finally{setDemandPhase(previous);}};\n"
                       "    Object.defineProperties(wrapped,Object.getOwnPropertyDescriptors(fn));api[name]=wrapped;\n"
                       "  }\n}\nexport async function loadApi() {")
                change('  const module=await import(url);', '  const module=await import(url);\n  demandWrapApi(module.default);')
                change('function readBaseCache(info,memo=null) {',
                       "function readBaseCache(info,memo=null) {\n"
                       "  const previous=setDemandPhase('cache-decode');\n"
                       "  try{return demandReadBaseCache(info,memo);}finally{setDemandPhase(previous);}\n"
                       "}\nfunction demandReadBaseCache(info,memo=null) {")
                dest.write_text(text)
                changes.append(dict(relative=str(relative), before=item, after=pin(dest), edits=edits))
            copied.append(pin(dest))
        assert {item['relative'] for item in changes} == {'tools/base-cache-graph.mjs', 'tools/typed-driver.mjs'}
        image = {key: (pin(project/Path(value['file']).relative_to(original)) if Path(value['file']).is_relative_to(original) else pin(value))
                 for key, value in observation['image'].items() if key in ['api', 'runtime', 'base', 'directRuntime', 'driver', 'source']}
        for key in ['api', 'runtime', 'base', 'directRuntime', 'source']:
            assert image[key]['sha256'] == observation['image'][key]['sha256']
        for item in inputs+originals:
            pin(item)
        plan = dict(kind='phase64-state09-demand-plan', complete=True, diagnosticOnly=True, productionQualified=False,
            sourcePreparation=pin(selected['result']), originalImage=observation['image'], node=config['node'],
            project=str(project), image=image, files=copied, changes=changes, copiedOriginals=originals,
            cache=[pin(project/Path(item['file']).relative_to(original)) for item in observation['verification']['cacheFiles']],
            inputs=inputs, cases=cases, scope='One fresh ordinary owned-path library request per case; only the explicitly '
            'derived driver and reviewed proxy helper change. API/Base/runtime/cache bytes are preserved. '
            'All nodes remain eagerly decoded. Proxy read counters are demand diagnostics, never latency measurements.')
        save(out/'plan.json', plan)
        command = ['python3', '-B', str(Path(__file__).resolve()), 'run', str(out/'plan.json'), str(out/'execution')]
        (out/'commands.txt').write_text(shlex.join(command)+'\n')
        print(json.dumps(dict(plan=pin(out/'plan.json'), command=command)))
        return
    plan = read(args.plan)
    assert plan['kind'] == 'phase64-state09-demand-plan' and plan['diagnosticOnly'] and not plan['productionQualified']
    for item in plan['inputs']+plan['files']+plan['copiedOriginals']:
        pin(item)
    sys.path.insert(0, str(TOOLS/'programs'))
    from support import ExecutionGuard
    out.mkdir(parents=True)
    result = dict(kind='phase64-state09-demand-results', complete=False, **{'pass': False},
        diagnosticOnly=True, timingClaims=False, plan=pin(args.plan), rows=[], failures=[])
    save(out/'report.json', result)
    with ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
        for case in plan['cases']:
            output = out/(case['id']+'.json')
            command = ['taskset', '-c', '3', plan['node']['file'], '--stack-size=4096', '--max-old-space-size=1024',
                       str(WORKER), str(args.plan.resolve()), case['id'], str(output)]
            execution = guard.run(command, out/(case['id']+'-process'), time.monotonic()+90)
            observation = read(output) if output.exists() else None
            passed = bool(execution['complete'] and execution.get('returncode') == 0 and observation and observation.get('pass'))
            result['rows'].append(dict(case=case['id'], execution=execution, observation=observation,
                result=pin(output) if output.exists() else None, success=passed))
            if not passed:
                result['failures'].append(case['id'])
            save(out/'report.json', result)
    for item in plan['inputs']+plan['files']+plan['copiedOriginals']:
        pin(item)
    assert pin(args.plan) == result['plan']
    result.update(complete=True, **{'pass': not result['failures']})
    save(out/'report.json', result)
    print(json.dumps({key: result[key] for key in ['complete', 'pass', 'failures']}))
    if not result['pass']:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
