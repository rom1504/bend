#!/usr/bin/env python3
"""Offline creator for current B1/B2 versus pinned Node TS, JS23 and C3."""
import argparse, hashlib, json, os, shutil
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
PERF = ROOT/'selfhost/tools/performance'


def pin(file):
    file = Path(file).resolve(strict=True)
    h = hashlib.sha256()
    with file.open('rb') as stream:
        for block in iter(lambda: stream.read(1024*1024), b''):
            h.update(block)
    return dict(file=str(file), sha256=h.hexdigest(), bytes=file.stat().st_size)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--check-only', action='store_true')
    a = p.parse_args(); os.sched_setaffinity(0, {0})
    out = a.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase91') and not out.exists()
    inputs = {}

    def bind(value):
        actual = pin(value['file'] if isinstance(value, dict) else value)
        if isinstance(value, dict):
            assert actual['sha256'] == value['sha256'], actual['file']
            if 'bytes' in value: assert actual['bytes'] == value['bytes']
        old = inputs.setdefault(actual['file'], actual)
        assert old == actual
        return actual

    def read(value):
        return json.loads(Path(bind(value)['file']).read_text())

    pins_id = bind(ROOT/'selfhost/build/phase90/compiler07-b2/image-pins.json')
    pins = read(pins_id)
    assert pins['kind'] == 'phase56-direct-image-pins'
    for key in ['producer','plan','attempt','emission','comparison','source','b1','b2','runtime','rootsReference','admission']:
        bind(pins[key])
    attempt = read(pins['attempt'])
    assert attempt['checked'] and attempt['artifactKind'] == 'derived-b1'
    assert bind(attempt['api']) == bind(pins['b1'])
    for row in attempt['snapshot']['sources']: bind(row['frozen'])
    for row in attempt['artifacts']: bind(row)
    boot = read(attempt['bootstrapReport'])
    assert boot['stage'] == 'upstream-bootstrap' and boot['provenance']['verifiedAfterBuild']
    assert boot['sourceSha256'] == pins['source']['sha256'] and boot['exports'] == pins['roots']
    validation = read(Path(pins['attempt']['file']).parent/'validation-001/report.json')
    assert validation['complete'] and validation['pass'] and validation['strictExact']
    emission, comparison = read(pins['emission']), read(pins['comparison'])
    assert emission['complete'] and emission['pass'] and bind(emission['module']) == bind(pins['b2'])
    assert emission['subject']['attempt']['sha256'] == pins['attempt']['sha256']
    assert comparison['complete'] and comparison['pass'] and comparison['observations'] == 8
    for role in ['source','direct']:
        probe = read(comparison[role])
        assert probe['complete'] and probe['pass'] and probe['emission']['sha256'] == pins['emission']['sha256']
    snapshot = Path(attempt['snapshot']['root'])
    old_c_id = bind(ROOT/'selfhost/build/phase82/paired04/plan.json')
    old_c = read(old_c_id)
    ts = {k: bind(v) for k,v in old_c['roles']['typescript'].items()}
    assert bind(attempt['node']) == ts['node']
    assert bind(attempt['base']) == ts['base']
    catalog_id = bind(PERF/'phase60/catalog.json'); catalog = read(catalog_id)
    assert catalog_id['sha256'] == 'd5903c18804afa14b9ca4fc51196d1d419148989a9496e768822f6637004c9ba'
    assert catalog['complete'] and catalog['pass'] and len(catalog['compileInputs']) == 23
    ts_oracles_id = bind(ROOT/'selfhost/build/phase66/head-ts-oracles01.json')
    ts_oracles = read(ts_oracles_id)
    old_js_id = bind(ROOT/'selfhost/build/phase66/b1-07-full-oracles.json'); old_js = read(old_js_id)
    assert ts_oracles['complete'] and ts_oracles['pass'] and old_js['complete'] and old_js['pass']
    assert ts_oracles['upstreamCommit'] == '059266225b77c8ca256ac6b25ee5c21449bab151'
    for record in ts_oracles['compilerInputs']: bind(record)
    for parent in [ts_oracles,old_js]:
        qualification = read(parent['semanticQualification'])
        assert qualification['complete'] and qualification['passed'] and qualification['inputsUnchanged']
    ts_js = {x['id']:x for x in ts_oracles['cases']}
    old_js_rows = {x['id']:x for x in old_js['cases']}
    cases = {'js':{}, 'c':{}}
    for row in catalog['compileInputs']:
        name, source = row['id'], bind(row['source'])
        # Exact original corpus contains no imports except implicit Base.
        assert all(x['file'] == source['file'] or x['file'].endswith('/base.bend') for x in row['files'])
        assert bind(ts_js[name]['source']) == source == bind(old_js_rows[name]['source'])
        cases['js'][name] = dict(source=source, tsOracle=bind(ts_js[name]['output']),
                                 historicalBendOracle=bind(old_js_rows[name]['output']), pointIds=row['pointIds'])
    assert list(old_c['cases']) == ['numeric','array','lexer']
    for name,row in old_c['cases'].items():
        cases['c'][name] = dict(source=bind(row['input']), tsOracle=bind(row['expected']['typescript']),
                                historicalBendOracle=bind(row['expected']['ordinary']))
    host = [Path('tools')/n for n in ['typed-driver.mjs','assemble.mjs','native-build.mjs',
            'node-resource-args.mjs','compiler-abi.mjs','base-cache-graph.mjs']]
    host += [Path(n) for n in ['src/runtime.mjs','src/compiler.json','src/runtime/js/direct.mjs']]
    host += [x.relative_to(snapshot) for x in (snapshot/'src/runtime/native').rglob('*') if x.is_file()]
    host = sorted(set(host))
    for relative in host: bind(snapshot/relative)
    methods = [bind(HERE/n) for n in ['prepare.py','worker.mjs','run.py']]
    support = bind(PERF/'programs/support.py')
    old_js_methods = [bind(ROOT/'selfhost/build/phase66/latency-method05'/n) for n in ['worker.mjs','run.py']]
    old_c_methods = [bind(PERF/'phase82'/n) for n in ['worker-v2.mjs','run-v2.py']]
    plan = dict(kind='phase91-current-compiler-latency-plan', node=ts['node'],
        execArgv=['--stack-size=4096','--max-old-space-size=1024'], cpu=3,
        rssMiB=2048, availableMiB=4096, minimumDiskMiB=160, maximumFileMiB=64,
        coreLimitBytes=0, secondsPerJob=90, rounds=3,
        roles=['b1','b2','typescript'], imagePins=pins_id, source=bind(pins['source']),
        typescript=ts, cases=cases, targets={}, methods=methods, support=support,
        historical=dict(js=old_js_id,typescriptJs=ts_oracles_id,c=old_c_id,jsMethods=old_js_methods,cMethods=old_c_methods),
        scope='Fresh Node processes, original JS23/C3 sources, 3 rotated rounds. Ordinary prepared Base. '
              'JS uses library/direct without report; C uses native withReport:true and no optional Base annotation product. '
              'Each stage measured separately; imports/API loading reported separately. No native-host or program-runtime timing.')
    for target in ['js','c']:
        project = out/(target+'-project')
        plan['targets'][target] = dict(project=str(project), selectedInputs=[], images={})
        for relative in host:
            source, destination = snapshot/relative, project/relative
            if not a.check_only:
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(source,destination)
                selected = bind(destination)
            else:
                selected = dict(bind(source),file=str(destination))
            plan['targets'][target]['selectedInputs'].append(selected)
        for role in ['b1','b2']:
            plan['targets'][target]['images'][role] = dict(api=bind(pins[role]),base=bind(attempt['base']),
                runtime=next(x for x in plan['targets'][target]['selectedInputs'] if x['file'].endswith('/src/runtime.mjs')),
                driver=next(x for x in plan['targets'][target]['selectedInputs'] if x['file'].endswith('/tools/typed-driver.mjs')))
    for expected in inputs.values(): assert pin(expected['file']) == expected
    if not a.check_only:
        plan['inputs'] = list(inputs.values())
        (out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n')
    print(json.dumps(dict(complete=True,targetExecuted=False,checkOnly=a.check_only,plan=str(out/'plan.json'),
          targets={t:len(cases[t]) for t in cases},cleanJobs=234,prepareJobs=6,
          copiedHostBytes=2*sum((snapshot/x).stat().st_size for x in host),inputFiles=len(inputs))))


if __name__ == '__main__': main()
