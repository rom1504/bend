"""Plan native reproduction of measured wrapper QBE, then bind exact receipts.

Metadata only. Native requests use the existing authenticated compact-carrier
transport, and full byte comparisons. No compiler or generated program runs here.
"""
import argparse
import importlib.util
import json
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
sys.path.insert(0, str(ROOT / 'selfhost/tools/profiler'))
from run import pin, verify, save

REQUEST = ROOT / 'selfhost/tools/performance/phase130/native-request.py'
CORPUS = ROOT / 'selfhost/tools/performance/phase112/benchmark45/manifest01.json'


def read(path):
    return json.loads(Path(path).read_text())


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('action', choices=['prepare', 'finish'])
    ap.add_argument('--out', type=Path, required=True)
    for name in ['image-build', 'image-request', 'admission', 'hosted-emission', 'screen', 'carrier-receipt']:
        ap.add_argument('--' + name, type=Path)
    ap.add_argument('--tag')
    a = ap.parse_args(); out = a.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase131')
    if a.action == 'prepare':
        assert not out.exists() and a.tag and all(c.isalnum() or c in '-_' for c in a.tag)
        paths = [a.image_build, a.image_request, a.admission, a.hosted_emission, a.screen, a.carrier_receipt]
        assert all(paths)
        build, acquisition, admission, emission, screen, _ = map(read, paths)
        assert all(x['complete'] for x in [build, acquisition, admission, emission, screen])
        assert admission['sourceChecked'] and admission['originalVerifiersUnchanged'] and admission['runtimeContractsUnchanged']
        assert admission['source'] == emission['source'] == acquisition['source']
        assert admission['api'] == emission['api'] and admission['runtime'] == emission['runtime']
        assert acquisition['kind'] == 'phase130-native-source-qbe-request' and acquisition['exitCode'] == 0
        assert not acquisition['changedInputs'] and acquisition['stderr']['bytes'] == 0
        assert acquisition['product'] in build['inputs'] and admission['runtime'] in build['inputs']
        assert len(screen['rows']) == 405 and all(r['correct'] and r['status'] == 0 for r in screen['rows'])
        corpus = read(CORPUS); names = [c['name'] for c in corpus['cases']]
        assert len(names) == 45 and [c['name'] for c in emission['cases']] == names
        spec = importlib.util.spec_from_file_location('native_transport', REQUEST)
        transport = importlib.util.module_from_spec(spec); spec.loader.exec_module(transport)
        carrier, base, carrier_inputs = transport.carrier_inputs(a.carrier_receipt)
        inputs = [pin(__file__), pin(REQUEST), pin(CORPUS), *map(pin, paths),
            *build['inputs'], build['binary'], *acquisition['inputs'], acquisition['product'],
            admission['source'], admission['api'], admission['runtime'], *carrier_inputs]
        builds = {b['name']: b['report'] for b in screen['builds']}
        rows, jobs = [], []
        for original, case in zip(corpus['cases'], emission['cases']):
            assert original['source'] == case['source']
            measured = read(builds[case['name']]['file']); assert measured['complete']
            assert case['qbe'] in measured['inputs'] and emission['runtime'] in measured['inputs']
            observations = [r for r in screen['rows'] if r['name'] == case['name'] and r['role'] == 'candidate']
            assert len(observations) == 3 and all(r['binary'] == measured['binary'] for r in observations)
            inputs += [case['source'], case['qbe'], builds[case['name']], measured['binary']]
            dest = ROOT / 'selfhost/build/phase130' / (a.tag + '-' + case['name'])
            assert not dest.exists()
            command = [sys.executable, '-B', str(REQUEST), '--image', build['binary']['file'],
                '--source', case['source']['file'], '--carrier-receipt', str(a.carrier_receipt.resolve()),
                '--out', str(dest), '--seconds', '30', '--expected-qbe', case['qbe']['file']]
            command = [sys.executable, '-B', str(ROOT / 'selfhost/tools/performance/phase111/guard.py'),
                '--out', str(out / (case['name'] + '-guard')), '--seconds', '60', '--rss-mib', '3072',
                '--available-mib', '16384', '--file-mib', '128', '--cpu', '3', '--', *command]
            jobs.append(dict(name=case['name'], seconds=75, command=command))
            rows.append(dict(name=case['name'], source=case['source'], expectedQbe=case['qbe'],
                measuredBinary=measured['binary'], receipt=str(dest / 'report.json')))
        for item in inputs: verify(item)
        out.mkdir(parents=True)
        jobs.append(dict(name='bind-native45-equality', seconds=60,
            command=[sys.executable, '-B', str(Path(__file__).resolve()), 'finish', '--out', str(out)]))
        plan = dict(complete=True, targetsRun=False, inputs=inputs, image=build['binary'],
            source=admission['source'], runtime=admission['runtime'], carrier=carrier['carrier'],
            stamp=carrier['stamp'], base=base, imageBuild=pin(a.image_build), imageRequest=pin(a.image_request),
            measuredScreen=pin(a.screen), cases=rows, jobs=jobs,
            scope='Empirical native output binding only, no native qualification claim. All45 exact measured wrappers through supplied image, compact carrier and raw-LF byte comparison. Root executes serial CPU3 guards; no output execution or rebuild.')
        save(out / 'plan.json', plan)
        print(json.dumps(dict(complete=True, targetsRun=False, plan=str(out / 'plan.json'), cases=45))); return
    plan = read(out / 'plan.json')
    for item in plan['inputs']: verify(item)
    rows = []; inputs = [pin(__file__), pin(out / 'plan.json'), *plan['inputs']]
    for case in plan['cases']:
        report = read(case['receipt'])
        assert report['kind'] == 'phase130-native-source-qbe-request' and report['complete'] and report['byteExact']
        assert report['image'] == plan['image'] and report['source'] == case['source']
        assert report['carrier'] == plan['carrier'] and report['stamp'] == plan['stamp'] and report['base'] == plan['base']
        assert report['runtime'] == plan['runtime'] and report['expectedQbe'] == case['expectedQbe']
        assert report['exitCode'] == 0 and not report['changedInputs'] and report['stderr']['bytes'] == 0
        for item in report['inputs'] + [report['product'], report['stderr']]: verify(item)
        assert report['product']['bytes'] == case['expectedQbe']['bytes'] and report['product']['sha256'] == case['expectedQbe']['sha256']
        inputs += [pin(case['receipt']), report['product']]
        rows.append(dict(name=case['name'], source=case['source'], nativeQbe=report['product'],
            hostedQbe=case['expectedQbe'], byteExact=True, measuredBinary=case['measuredBinary'],
            receipt=pin(case['receipt']), nativeSeconds=report['nativeSeconds']))
    assert not (out / 'report.json').exists()
    save(out / 'report.json', dict(complete=True, targetsRun=False, inputs=inputs, image=plan['image'],
        source=plan['source'], runtime=plan['runtime'], cases=rows, all45ByteExact=True,
        measuredScreen=plan['measuredScreen'], nativeRequestSeconds=sum(r['nativeSeconds'] for r in rows),
        performanceReexecutionRequired=False, nativeQualificationEstablishedByThisGate=False,
        scope='Native compiler reproduces all45 measured whole-QBE products byte for byte. The same runtime and retained build products bind the existing405 observations to those outputs. No extra timing is needed for identical code; source self-reproduction, focused and ordinary native qualification remain independent.'))
    print(json.dumps(dict(complete=True, targetsRun=False, all45ByteExact=True, nativeRequestSeconds=sum(r['nativeSeconds'] for r in rows))))


if __name__ == '__main__': main()
