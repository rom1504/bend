#!/usr/bin/env python3
"""Prepare the qualified compact-carrier N1 profile; never execute a target.

Reuse the frozen Phase129 request sources/oracles and generic profiler. A runtime
relink supplies active dispatch contexts/counters without rebuilding the compiler.
"""
import argparse
import copy
import importlib.util
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[5]
PROF = ROOT/'selfhost/tools/profiler'
sys.path.insert(0, str(PROF))
from run import all_pins, pin, save, verify


def load(path):
    return json.loads(Path(path).read_text())


def jobs(out, manifest, diagnostic=False):
    # The compact carrier shortened the small case. Eight pairs target roughly
    # 650 samples there; no capture is admitted solely because of this budget.
    result = []
    for work in manifest['workloads']:
        pairs = 8 if work['name'] == 'coverage-closures-256' else 2
        command = [sys.executable, '-B', str(PROF/'run.py'), '--manifest',
            str(out/'manifest.json'), '--out', str(out/work['name']),
            '--names', work['name'], '--modes',
            'clean,sample,events' if diagnostic else 'clean,sample',
            '--rounds', '1' if diagnostic else '3', '--periods-us',
            ','.join(['8000', '13000']*pairs)]
        result.append(dict(name=work['name'], command=command, seconds=150,
                           plannedSamplePairs=pairs))
    return dict(jobs=result, targetsRun=False, minimumAcceptedPooledSamples=500,
                scope='Planning only; loss, CPU-window and output gates remain mandatory.')


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('action', choices=['physical', 'runtime', 'seal'])
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--physical', type=Path, help='Prepared physical directory for runtime/seal')
    a = ap.parse_args(); out = a.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase131')
    candidate = ROOT/'implementation/phase130/candidate.json'; c = load(candidate)
    assert c['complete'] and c['nativeQualified'] and not c['installed']
    qualification = load(verify(c['qualification']))
    assert qualification['complete'] and qualification['nativeQualified'] and qualification['byteExact']
    assert all(c[k] == qualification[k] for k in ['source', 'n1', 'runtime'])
    build_pin = qualification['reports']['n1Build']; build = load(verify(build_pin))
    qbe = qualification['hostedQbe']
    assert build['complete'] and build['binary'] == c['n1']
    assert qbe in build['inputs'] and c['runtime'] in build['inputs']
    runtime_report = load(verify(c['runtimeReport']))
    assert runtime_report['complete'] and runtime_report['object'] == c['runtime']
    evidence = [pin(__file__), pin(candidate), c['qualification'], c['admission'],
        c['source'], c['sourceManifest'], c['runtime'], c['runtimeReport'],
        c['n1'], build_pin, build['object'], qbe, c['preferredCarrierReceipt']]
    for item in evidence: verify(item)
    if a.action == 'physical':
        assert not out.exists()
        method = ROOT/'selfhost/tools/performance/phase130/native-request.py'
        spec = importlib.util.spec_from_file_location('p130_request', method)
        native = importlib.util.module_from_spec(spec); spec.loader.exec_module(native)
        carrier, base, carrier_inputs = native.carrier_inputs(Path(c['preferredCarrierReceipt']['file']))
        assert carrier['carrier'] == c['preferredCarrier'] and carrier['stamp'] == c['preferredStamp']
        original = ROOT/'selfhost/build/phase129/profile01/manifest.json'
        manifest = copy.deepcopy(load(original))
        for item in all_pins(manifest): verify(item)
        manifest['inputs'] += [pin(original), pin(method), *evidence, *carrier_inputs]
        manifest['scope'] = ('Qualified Phase130 N1 compact carrier, frozen three cold requests. '
            'Exact pre-existing whole-QBE oracles. Historical Phase129 is analyzed separately; '
            'different carrier/compiler identities must not be pooled.')
        for work in manifest['workloads']:
            variant = work['variants'][0]; cmd = variant['command']
            assert cmd[1:8] == ['--threads','1','--gpu','off','--','phase111',cmd[7]]
            assert cmd[8] == base['file'] and cmd[9] == 'cache' and len(cmd) == 12
            variant['name'] = 'phase130'; variant['binary'] = c['n1']
            cmd[0] = c['n1']['file']; cmd[10] = carrier['carrier']['file']; cmd[11] = carrier['stamp']
            variant['inputs'] = [pin(x) for x in cmd if Path(x).is_file()]
        for item in all_pins(manifest): verify(item)
        out.mkdir(parents=True); save(out/'manifest.json', manifest)
        save(out/'jobs.json', jobs(out, manifest))
    else:
        assert a.physical is not None
        original = a.physical.resolve()/'manifest.json'; manifest = load(original)
        for item in all_pins(manifest): verify(item)
        assert all(w['variants'][0]['binary'] == c['n1'] for w in manifest['workloads'])
        if a.action == 'runtime':
            assert not out.exists(); out.mkdir(parents=True)
            rt = Path(c['runtime']['file']).parent
            headers = re.findall(r'^#include "([^"\n]+)"', (rt/'runtime.c').read_text(), re.M)
            inputs = dict(runtime=pin(rt/'runtime.c'), headers=[pin(rt/x) for x in headers],
                programObject=build['object'], compiler='/usr/bin/gcc', linker='/usr/bin/gcc',
                compileFlags=['-O2','-std=gnu11','-ffp-contract=off'],
                evidence=[*evidence, pin(original)])
            save(out/'runtime-input.json', inputs)
            subprocess.run([sys.executable,'-B',str(PROF/'runtime.py'),'--manifest',
                str(out/'runtime-input.json'),'--out',str(out/'runtime')], check=True)
            subprocess.run([sys.executable,'-B',str(PROF/'owners.py'),'--qbe',qbe['file'],
                '--output',str(out/'owners.json')], check=True)
        else:
            report = out/'build/report.json'; b = load(report)
            assert b['complete']; diagnostic = next(x for x in b['products'] if Path(x['file']).name == 'program')
            verify(diagnostic)
            manifest['inputs'] += [pin(original),pin(report),pin(out/'runtime/plan.json'),*evidence]
            manifest['scope'] = ('Diagnostic relink of exact qualified Phase130 N1 object/runtime source. '
                'Context-only samples and event counters have distinct overhead. Never a clean baseline.')
            for work in manifest['workloads']:
                variant = work['variants'][0]; variant['name'] = 'phase130-context'
                variant['binary'] = diagnostic; variant['command'][0] = diagnostic['file']
                variant['dispatchInstrumentation'] = True
            assert not (out/'manifest.json').exists()
            save(out/'manifest.json',manifest); save(out/'jobs.json',jobs(out,manifest,True))
    print(json.dumps(dict(complete=True,targetsRun=False,action=a.action,out=str(out))))


if __name__ == '__main__': main()
