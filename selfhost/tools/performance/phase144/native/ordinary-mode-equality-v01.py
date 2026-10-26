"""Offline exact ordinary-mode hosted/native product join; runs no targets."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]
INPUTS = {}


def pin(path):
    path = Path(path).resolve()
    digest = hashlib.sha256()
    size = 0
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(chunk)
            size += len(chunk)
    return dict(file=str(path), bytes=size, sha256=digest.hexdigest())


def retain(value):
    if isinstance(value, dict):
        if {'file', 'bytes', 'sha256'} <= value.keys():
            expected = {k: value[k] for k in ['file', 'bytes', 'sha256']}
            assert pin(expected['file']) == expected, expected['file']
            prior = INPUTS.get(expected['file'])
            assert prior is None or prior == expected
            INPUTS[expected['file']] = expected
        for child in value.values():
            retain(child)
    elif isinstance(value, list):
        for child in value:
            retain(child)


def read(path):
    retain(pin(path))
    return json.loads(Path(path).read_text())


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out', type=Path, required=True)
    a = ap.parse_args()
    out = a.out.resolve()
    assert not out.exists() and out.parent == ROOT/'selfhost/build/phase144'
    method = Path(__file__).resolve()
    workflow = method.with_name('workflow-v04.py')
    assert pin(workflow)['sha256'] == '69bf4b23f46776ee26de1ab47fb947cd958ad08658f73ffc4589b1d4ed65553e'
    spec = importlib.util.spec_from_file_location('ordinary_mode_workflow', workflow)
    W = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(W)
    retain([pin(method), pin(workflow)])
    plan_path = ROOT/'selfhost/build/phase144/final04-plan/plan.json'
    hosted_path = ROOT/'selfhost/build/phase144/final04-small-products01/report.json'
    plan, hosted = read(plan_path), read(hosted_path)
    ad = plan['sourceAdmission']
    assert plan['complete'] and ad['source']['sha256'] == '865cff6a02da261952cac824bed0fe91882e60f1c6e4062fbe57f5804745c4ed'
    api = read(ad['checkedApi']['file'])
    assert api['complete'] and api['checked'] and api['status'] == 0
    assert api['api'] == ad['api'] and ad['source'] in api['inputs']
    assert api['command'][2:4] == [ad['source']['file'], ad['api']['file']]
    assert hosted['complete'] and ad['checkedApi'] in hosted['inputs'] and ad['api'] in hosted['inputs']
    assert ad['source'] in hosted['inputs']
    retain(api); retain(hosted['inputs'])
    paths = {k: Path(v)/'report.json' for k, v in plan['paths'].items()}
    b1 = W.pipe(paths['n1'], plan['producer'], ad['source'], plan['runtime'], plan)
    b2 = W.pipe(paths['n2'], b1['binary'], ad['source'], plan['runtime'], plan)
    # Authenticate native source, actual linked runtime and machine outputs. The
    # complete qualification, self fixed point and host effects have other gates.
    for path, build in [(paths['n1'], b1), (paths['n2'], b2)]:
        read(path)
        retain(build)
    suite = read(paths['n2-full45'])
    assert suite['complete'] and suite['passed'] and len(suite['rows']) == 45
    retain(suite['inputs'])
    rows = []
    names = ['lexer', 'coverage-map-churn-128', 'coverage-closures-256']
    assert [c['name'] for c in hosted['cases']] == names
    for h in hosted['cases']:
        n = next(r for r in suite['rows'] if r['name'] == h['name'])
        assert n['status'] == 'passed' and all(n[k] for k in ['compiled', 'built', 'executed', 'semanticPass'])
        assert h['verified'] and not n['expectedRefusal']
        retain(h); retain(n)
        e = read(n['emission']['file'])
        assert e['complete'] and e['image'] == b2['binary'] and e['imageReceipt'] == pin(paths['n2'])
        assert e['product'] == n['product'] and h['source'] in e['inputs']
        assert e['buildReport'] == n['build']
        request = e['jobs'][0]
        assert request['label'] == 'native-request' and request['status'] == 'complete' and request['exitCode'] == 0
        assert request['command'][:8] == [b2['binary']['file'], '--threads', '1', '--gpu', 'off', '--', 'phase111', h['source']['file']]
        assert request['command'][9] == 'cache' and request['stdout'] == n['product'] and request['stderr']['bytes'] == 0
        build = read(n['build']['file'])
        assert build['complete'] and build['outputExact'] and build['binary'] == n['binary']
        assert n['product'] in build['inputs'] and plan['runtime'] in build['inputs'] and h['expected'] in build['inputs']
        assert [j['label'] for j in build['jobs']] == ['qbe', 'assemble', 'link', 'execute']
        assert all(j['exitCode'] == 0 for j in build['jobs'])
        link, run = build['jobs'][2:]
        assert link['command'][1:] == ['-no-pie', build['object']['file'], plan['runtime']['file'], '-pthread', '-lm', '-o', n['binary']['file']]
        assert run['command'] == [n['binary']['file'], '--threads', '1', '--gpu', 'off']
        assert run['stdout'] == n['observation'] and run['stderr']['bytes'] == 0
        assert Path(run['stdout']['file']).read_bytes() == Path(h['expected']['file']).read_bytes()
        assert Path(h['qbe']['file']).read_bytes() == Path(n['product']['file']).read_bytes()
        retain(e); retain(build)
        rows.append(dict(name=h['name'], source=h['source'], hostedProduct=h['qbe'], nativeProduct=n['product'],
            byteExact=True, emission=n['emission'], build=n['build'], independentStdout=h['expected'],
            observation=n['observation'], outputExact=True))
    # Rehash independently of the imported authority's memoization.
    for expected in list(INPUTS.values()):
        assert pin(expected['file']) == expected
    result = dict(kind='phase144-ordinary-mode-hosted-native-equality', complete=True, passed=True,
        targetsRun=False, nativeQualified=False, incrementalQualified=False,
        plan=pin(plan_path), compilerSource=ad['source'], checkedApi=ad['checkedApi'], api=ad['api'],
        image=b2['binary'], imageReceipt=pin(paths['n2']), runtime=plan['runtime'],
        runtimeAuthority=pin(paths['n2']), hostedReport=pin(hosted_path), full45=pin(paths['n2-full45']),
        mode='ordinary-source-request', rows=rows, inputs=list(INPUTS.values()),
        carrierCaveat='Hosted uses the compact prepared-Base carrier; native full45 uses the historical prepared-Base carrier. Same sources and complete QBE products are compared directly; no equal preparation cost is claimed.',
        scope='Offline exact QBE identity for three ordinary hosted/native requests and their existing independent stdout observations. Actual N2 source and linked runtime are bound. No new target, timing, whole-compiler qualification or ordinary/session cross-mode identity claim.')
    out.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(complete=True, passed=True, cases=len(rows), report=pin(out))))


if __name__ == '__main__':
    main()
