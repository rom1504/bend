#!/usr/bin/env python3
"""Authenticate one identical Phase192 N1/N2 request; run no compiler/target."""
import argparse
import json
import shlex
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path[:0] = [str(ROOT/'selfhost/tools/build'), str(ROOT/'selfhost/tools/profiler')]
import common as C
import request as R
import freeze as F

PHASE = ROOT/'selfhost/build/phase192'
CASE = 'test-map-set-ops'


def read(path):
    return json.loads(Path(path).read_text())


def equal_bytes(a, b):
    C.verify(a)
    C.verify(b)
    C.require(all(a[k] == b[k] for k in ('bytes', 'sha256')), 'Different complete bytes')


def prepare(out):
    sampler_receipt = ROOT/'selfhost/build/phase159/thread-sampler01/report.json'
    sampler = read(sampler_receipt)
    C.require(sampler['complete'] and sampler['returncode'] == 0 and
              sampler['samplerScope'] == 'all_created_threads', 'Invalid sampler build')
    C.verify(sampler['sampler'])
    for item in sampler['snapshots']:
        C.verify(item)
    hosted_path = PHASE/'hosted-native-compare01/report.json'
    hosted = read(hosted_path)
    C.require(hosted['complete'], 'Incomplete independent hosted comparison')
    independent = next(r for r in hosted['rows'] if r['id'] == CASE)
    C.require(independent['objectIdentical'], 'Hosted/N1 object disagreement')
    oracle = independent['left']['object']
    equal_bytes(oracle, independent['right']['object'])
    for key in ('buildReceipt', 'oracleReceipt'):
        C.verify(independent['left'][key])
    compiler_source = C.pin(PHASE/'selected-source01/compiler.bend')
    roles, variants, requests = {}, [], []
    for alias, directory, stage, acquisition in [
            ('qbe_n1', 'native-image01', 'N1', 'native45-01'),
            ('x86_n2', 'native-self01', 'N2', 'native45-02')]:
        image_receipt = PHASE/directory/'report.json'
        image = read(image_receipt)
        C.require(image['complete'] and not image['changedInputs'], 'Incomplete image')
        binding = image['imageBinding']
        C.require(binding['stage'] == stage and binding['sourceIdentity'] == compiler_source,
                  'Image source/stage mismatch')
        C.require(image['target'] == ('qbe' if stage == 'N1' else 'x86'),
                  'Image producer target mismatch')
        C.verify(image['binary'])
        acquisition_path = PHASE/acquisition/'report.json'
        acquired = read(acquisition_path)
        C.require(acquired['complete'] and not acquired['changedInputs'], 'Incomplete acquisition')
        row = next(r for r in acquired['rows'] if r['id'] == CASE)
        C.require(row['complete'] and row['status'] == 'executed-independent-oracle-pass',
                  'Missing independent program oracle')
        built = read(C.verify(row['buildReceipt']))
        C.verify(row['oracleReceipt'])
        C.require(built['complete'] and not built['changedInputs'], 'Incomplete request')
        old = built['request']
        equal_bytes(oracle, row['object'])
        parser = argparse.ArgumentParser()
        R.arguments(parser)
        args = parser.parse_args(['--workspace', str(ROOT), '--assets', str(PHASE/'assets.json'),
            '--image', binding['image']['file'], '--image-receipt', str(image_receipt),
            '--source', old['source']['file'], '--host', 'native', '--stage', stage,
            '--target', 'x86', '--emit', 'object', '--mode', 'cache',
            '--expected-object', oracle['file'], '--seconds', '12', '--out', str(out/alias)])
        request = R.plan(args)
        C.require(request['command'] == old['command'] and request['outputContract'] == 'stdout',
                  'Frozen request command/contract differs')
        C.require(request['imageMetadata'] == binding, 'Request image binding differs')
        pins = [*request['inputs'], C.pin(image_receipt), C.pin(acquisition_path),
                row['buildReceipt'], row['oracleReceipt'], compiler_source]
        for item in pins:
            C.verify(item)
        roles[alias] = dict(image=image['binary'], imageReceipt=C.pin(image_receipt),
            stage=stage, producerTarget=image['target'], compilerSource=compiler_source,
            request=request, priorEmissionSeconds=built['emissionSeconds'])
        variants.append(dict(name=alias, command=request['command'], argv0='compiler-work',
            runtimeArgumentConvention=request['runtimeArgumentConvention'],
            stdout=oracle['file'], stderr=str(ROOT/'selfhost/tools/bench/examples/expected-empty.stderr'),
            inputs=[p['file'] for p in pins]))
        requests.append(request)
    a, b = requests
    C.require(a['command'][1:] == b['command'][1:], 'Request argument tails differ')
    for key in ('source', 'base', 'carrier', 'stamp', 'imageRuntime', 'runtimeArgumentConvention'):
        C.require(a[key] == b[key], 'Request inputs differ: '+key)
    C.require(roles['x86_n2']['request']['imageMetadata']['producer'] == roles['qbe_n1']['image'],
              'N2 was not produced by selected N1')
    scope = ('Identical fresh-process cache-mode source-to-x86-object request under same-source '
             'Phase192 QBE-produced N1 and x86-produced N2. Fixed map/set fixture, not full '
             'compiler-source self-build. Complete stdout equals a preexisting checked-hosted '
             'object; no assembler, linker or generated program execution. Physical sampling '
             'is diagnostic; only uninstrumented clean runs measure request speed.')
    out = C.fresh_output(out, ROOT)
    recipe = dict(cwd=str(ROOT), sampler=sampler['sampler']['file'], scope=scope,
        inputs=[str(Path(__file__).resolve()), str(hosted_path), str(sampler_receipt),
                *[p['file'] for p in sampler['snapshots']],
                *[independent['left'][k]['file'] for k in ('buildReceipt', 'oracleReceipt')],
                str(ROOT/'implementation/phase192/evidence.json')],
        workloads=[dict(name=CASE, timeoutSeconds=12, variants=variants)])
    C.write_json(out/'recipe.json', recipe)
    C.write_json(out/'manifest.json', F.freeze(recipe, out/'recipe.json'))
    C.write_json(out/'roles.json', dict(complete=True, targetsRun=False, roles=roles,
        independentOutput=oracle, independentComparison=C.pin(hosted_path), scope=scope))
    capture = out.parent/'compiler-profile01'
    command = ['python3', '-B', 'selfhost/tools/build-retention/guard.py', '--out',
        str(out.parent/'compiler-profile01-guard'), '--run-root', str(capture),
        '--disk-mib', '128', '--seconds', '150', '--rss-mib', '2048',
        '--available-mib', '16384', '--file-mib', '64', '--cpu', '3', '--',
        'python3', '-B', 'selfhost/tools/profiler/run.py', '--manifest', str(out/'manifest.json'),
        '--out', str(capture), '--modes', 'clean,sample', '--rounds', '2',
        '--periods-us', '8000,13000,8000,13000']
    C.write_json(out/'plan.json', dict(complete=True, targetsRun=False,
        manifest=C.pin(out/'manifest.json'), roles=C.pin(out/'roles.json'),
        guardCommand=command, cleanRequests=4, sampledRequests=8,
        perRequestSeconds=12, wholeRunSeconds=150, diskMiB=128,
        expectedTargetSeconds=6*sum(r['priorEmissionSeconds'] for r in roles.values()),
        note='Historical durations are planning evidence, not current timing results.'))
    print(shlex.join(command))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    prepare(parser.parse_args().out.resolve())
