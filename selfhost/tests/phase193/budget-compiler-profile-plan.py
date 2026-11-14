#!/usr/bin/env python3
"""Freeze one optional cross-source N2 profile from validated cost-plan inputs only."""
import argparse
import json
import shlex
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path[:0] = [str(ROOT/'selfhost/tools/build'), str(ROOT/'selfhost/tools/profiler')]
import common as C
import freeze as F

PHASE = ROOT/'selfhost/build/phase193'
CASE = 'test-map-set-ops'


def read(path):
    return json.loads(Path(path).read_text())


def prepare(cost_plan, out):
    preparation = read(cost_plan/'report.json')
    C.require(preparation['complete'] and preparation['stage'] == 'N2', 'Incomplete N2 cost plan')
    manifest = read(C.verify(preparation['manifest']))
    C.require(manifest['kind'] == 'compiler' and manifest['reference'] == 'baseline'
              and set(manifest['roles']) == {'baseline', 'candidate'}, 'Wrong cost-plan roles')
    for pin in manifest['inputs']:
        C.verify(pin)
    case = next(row for row in manifest['cases'] if row['id'] == CASE)
    C.verify(case['source'])
    sampler_receipt = ROOT/'selfhost/build/phase159/thread-sampler01/report.json'
    sampler = read(sampler_receipt)
    C.require(sampler['complete'] and sampler['returncode'] == 0
              and sampler['samplerScope'] == 'all_created_threads', 'Invalid sampler')
    for pin in [sampler['sampler'], *sampler['snapshots']]:
        C.verify(pin)
    roles, variants, requests = {}, [], []
    for alias in ('baseline', 'candidate'):
        acquisition_pin = preparation[alias+'Acquisition']
        acquired = read(C.verify(acquisition_pin))
        C.require(acquired['complete'] and not acquired['changedInputs'], 'Incomplete acquisition')
        row = next(row for row in acquired['rows'] if row['id'] == CASE)
        C.require(row['complete'] and row['status'] == 'executed-independent-oracle-pass',
                  'Missing independent runtime oracle: '+alias)
        built = read(C.verify(row['buildReceipt']))
        C.verify(row['oracleReceipt'])
        C.require(built['complete'] and not built['changedInputs'], 'Incomplete object build')
        old = built['request']
        request = case['requests'][alias]
        role = manifest['roles'][alias]
        C.require(request['command'] == old['command'] and old['outputContract'] == 'stdout'
                  and request['stdout'] == row['object'] == built['object']
                  and case['source'] == old['source'] == row['source']
                  and role['compiler'] == old['image'] and role['runtime'] == old['imageRuntime']
                  and old['imageMetadata']['stage'] == 'N2', 'Frozen request binding differs')
        image_receipt = Path(old['image']['file']).parent/'report.json'
        image = read(image_receipt)
        C.require(image['complete'] and not image['changedInputs'] and image['target'] == 'x86'
                  and image['imageBinding'] == old['imageMetadata'], 'Wrong N2 image binding')
        source = old['imageMetadata']['sourceIdentity']
        expected_source = (ROOT/'selfhost/build/phase192/selected-source01/compiler.bend'
                           if alias == 'baseline' else PHASE/'selected-source02/compiler.bend')
        C.require(source == C.pin(expected_source), 'Wrong frozen compiler source')
        if alias == 'candidate':
            C.require(source == preparation['candidateSource'], 'Candidate source differs')
        pins = [*request['inputs'], *old['inputs'], source, C.pin(image_receipt),
                acquisition_pin, row['buildReceipt'], row['oracleReceipt'],
                request['stdout'], request['stderr']]
        for pin in pins:
            C.verify(pin)
        C.require(request['stderr']['bytes'] == 0, 'Expected stderr must be empty')
        roles[alias] = dict(compiler=role['compiler'], compilerSource=source,
            imageReceipt=C.pin(image_receipt), acquisition=acquisition_pin,
            object=request['stdout'], buildReceipt=row['buildReceipt'], oracleReceipt=row['oracleReceipt'],
            command=request['command'], priorEmissionSeconds=built['emissionSeconds'])
        variants.append(dict(name=alias, command=request['command'],
            runtimeArgumentConvention=old['runtimeArgumentConvention'],
            stdout=request['stdout']['file'], stderr=request['stderr']['file'],
            inputs=list(dict.fromkeys(pin['file'] for pin in pins))))
        requests.append(old)
    a, b = requests
    C.require(a['command'][1:] == b['command'][1:], 'Request arguments differ')
    for key in ('source', 'base', 'carrier', 'stamp', 'imageRuntime', 'runtimeArgumentConvention'):
        C.require(a[key] == b[key], 'Request input differs: '+key)
    C.require(roles['baseline']['compilerSource'] != roles['candidate']['compilerSource'],
              'Expected distinct compiler source identities')
    scope = ('Optional same-input map/set compiler request comparison: Phase192 N2 baseline versus '
             'Phase193 budget N2 candidate, with different compiler sources and generated implementations. '
             'Fresh-process cache-mode source-to-x86-object; identical user source, Base, carrier, stamp '
             'and linked runtime. Each role reproduces its own independently runtime-validated frozen '
             'object; the two object outputs differ. This does not isolate generated-code effects from '
             'compiler-source changes, establish bootstrap qualification, or measure full compiler '
             'self-build. Clean runs measure request cost; sampled runs diagnose physical CPU owners.')
    out = C.fresh_output(out, ROOT)
    recipe = dict(cwd=str(ROOT), sampler=sampler['sampler']['file'], scope=scope,
        inputs=list(dict.fromkeys([str(Path(__file__).resolve()), str(cost_plan/'report.json'),
            preparation['manifest']['file'], str(sampler_receipt),
            *[pin['file'] for pin in sampler['snapshots']],
            *[pin['file'] for pin in manifest['inputs']]])),
        workloads=[dict(name=CASE, timeoutSeconds=12, variants=variants)])
    C.write_json(out/'recipe.json', recipe)
    C.write_json(out/'manifest.json', F.freeze(recipe, out/'recipe.json'))
    C.write_json(out/'roles.json', dict(complete=True, targetsRun=False, roles=roles,
        requestSource=case['source'], costPreparation=C.pin(cost_plan/'report.json'), scope=scope))
    capture = PHASE/'budget-compiler-profile01'
    run = ['python3', '-B', 'selfhost/tools/profiler/run.py', '--manifest', str(out/'manifest.json'),
           '--out', str(capture), '--modes', 'clean,sample', '--rounds', '2',
           '--periods-us', '8000,13000,8000,13000']
    guarded = ['python3', '-B', 'selfhost/tests/phase193/job.py', '--file-mib', '64',
               'budget-compiler-profile01', '150', '128', *run]
    compare = ['python3', '-B', 'selfhost/tools/profiler/compare.py', '--report',
               str(capture/'report.json'), '--reference', 'baseline', '--out', str(capture/'comparison.json')]
    render = ['python3', '-B', 'selfhost/tools/profiler/render.py', '--comparison',
              str(capture/'comparison.json'), '--out', str(capture/'summary.md')]
    C.write_json(out/'plan.json', dict(complete=True, targetsRun=False, optional=True,
        manifest=C.pin(out/'manifest.json'), roles=C.pin(out/'roles.json'), scope=scope,
        guardCommand=guarded, compareCommand=compare, renderCommand=render,
        cleanRequests=4, sampledRequests=8, periodsUs=[8000,13000,8000,13000],
        perRequestSeconds=12, wholeRunSeconds=150, diskMiB=128,
        expectedTargetSeconds=6*sum(role['priorEmissionSeconds'] for role in roles.values()),
        admission='Root schedules only after qualification and current lane/disk admission.',
        interpretation='Historical durations estimate cost only. Retain default profiler quality gates; '
                       'no profile claim before capture, output checks and quality acceptance.'))
    print(shlex.join(guarded))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--cost-plan', type=Path, default=PHASE/'budget-compiler-cost-n2-plan01')
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    prepare(args.cost_plan.resolve(), args.out.resolve())
