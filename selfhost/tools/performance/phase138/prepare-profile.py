#!/usr/bin/env python3
"""Plan/seal a relink of qualified Phase137 N3; never execute the target."""
import argparse
import copy
import importlib.util
import json
import pathlib
import sys

sys.dont_write_bytecode = True
ROOT = pathlib.Path(__file__).resolve().parents[4]
PROF = ROOT / 'selfhost/tools/profiler'
sys.path.insert(0, str(PROF))
from run import pin, verify, save, all_pins
from owners import parse_qbe_owners

def read(path):
    return json.loads(pathlib.Path(path).read_text())

def unique(pins):
    return list({(p['file'], p['sha256']): p for p in pins}.values())

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['prepare', 'seal'])
    parser.add_argument('--out', type=pathlib.Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase138')
    selected = ROOT / 'implementation/phase137/candidate.json'
    c = read(selected)
    q = read(verify(c['qualification']))
    b = read(verify(q['reports']['n3_build']))
    assert c['nativeQualified'] and q['nativeQualified'] and b['complete']
    assert c['preferredNative'] == c['n3'] == q['n3'] == b['binary']
    assert q['qbe']['q3'] in b['inputs'] and c['runtime'] in b['inputs']
    # Reuse the previous authenticated diagnostic-runtime provenance checks.
    prior = ROOT / 'selfhost/tools/performance/phase136/profiling/prepare-v01.py'
    spec = importlib.util.spec_from_file_location('prior_profile', prior)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    oldc, _, _, oldplan, runtime, oldevidence = module.lineage()
    assert oldc['runtime'] == c['runtime']
    coldpath = ROOT / 'selfhost/build/phase134/p137-cold-candidate01/report.json'
    cold = read(coldpath)
    assert cold['complete'] and cold['image'] == c['n3'] and cold['runtime'] == c['runtime']
    assert cold['compilerExitCode'] == cold['qbeExitCode'] == 0
    original = ROOT / 'selfhost/build/phase136/profile01/manifest.json'
    template = read(original)
    evidence = unique([pin(__file__), pin(prior), pin(selected), c['qualification'],
        c['source'], c['sourceManifest'], c['n3'], c['runtime'], c['runtimeReport'],
        q['reports']['n3_build'], b['object'], q['qbe']['q3'], pin(coldpath),
        pin(original), *oldevidence, *template['inputs']])
    for item in evidence:
        verify(item)
    if args.action == 'prepare':
        out.mkdir(parents=True, exist_ok=False)
        (out / 'runtime').mkdir()
        plan = copy.deepcopy(oldplan)
        job = copy.deepcopy(plan['jobs'][1])
        job['command'][2] = b['object']['file']
        job['command'][-1] = str(out / 'runtime/program')
        assert job['command'][3] == runtime['file']
        plan.update(inputs=evidence, outputs=[], jobs=[job], compiled=False,
                    executed=False, reusedRuntimeObject=runtime,
                    scope='Exact Phase137 N3 object relink; no compiler/runtime compilation.')
        save(out / 'runtime/plan.json', plan)
        save(out / 'owners.json', parse_qbe_owners(q['qbe']['q3']['file']))
        template.update(inputs=evidence, ownerMap=pin(out / 'owners.json'),
            lineage=dict(nativeQualified=True, source=c['source'], image=c['n3'],
                qbe=q['qbe']['q3'], programObject=b['object'], qualification=c['qualification']),
            scope='One sample-only frozen compiler-A request. Compare retained clean digest, not independent semantic oracle. No clean speed ratio.')
        template.pop('diagnosticImage', None)
        v = template['workloads'][0]['variants'][0]
        assert v['command'][1:] == cold['compilerCommand'][1:]
        v['expected']['stdout'] = dict(kind='exact', **cold['irDigest'])
        template['resourcePlan'].update(outerGuardSeconds=660, innerTargetTimeoutSeconds=600,
            treeRssLimitMiB=4096, availableFloorMiB=16384, fileSizeLimitMiB=256, cpu=3)
        save(out / 'template.json', template)
    else:
        assert not (out / 'manifest.json').exists()
        built = read(out / 'build/report.json')
        plan = read(out / 'runtime/plan.json')
        assert built['complete'] and built['plan'] == pin(out / 'runtime/plan.json')
        assert len(built['jobs']) == 1
        job = built['jobs'][0]
        assert job['command'] == plan['jobs'][0]['command']
        assert job['returncode'] == 0 and not job['timedOut']
        diagnostic = job['product']
        template = read(out / 'template.json')
        v = template['workloads'][0]['variants'][0]
        v.update(name='phase137-qualified-n3-context', binary=diagnostic)
        v['command'][0] = diagnostic['file']
        v['inputs'] = [pin(p) for p in v['command'] if pathlib.Path(p).is_file()]
        template['diagnosticImage'] = diagnostic
        template['inputs'] = unique([*template['inputs'], pin(out / 'runtime/plan.json'),
            pin(out / 'build/report.json'), template['ownerMap'], diagnostic])
        for item in all_pins(template):
            verify(item)
        save(out / 'manifest.json', template)
    print(json.dumps(dict(complete=True, targetsRun=False, action=args.action, out=str(out))))

if __name__ == '__main__':
    main()
