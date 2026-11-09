#!/usr/bin/env python3
"""Bounded final x86 image sampling/ELF/source-owner control, under one outer guard.

One clean request and one sampled request must reproduce the complete assembly
from an independent successful qualification. This is an operational control,
not a statistically admitted profile, runtime comparison or compiler promotion.
"""
import argparse
import json
import os
from pathlib import Path
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
PHASE = ROOT / 'selfhost/build/phase183'
PROFILER = ROOT / 'selfhost/tools/profiler'
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
import request
from common import changed_inputs, fresh_output, pin, require, run, timeout, verify, write_json

EMITTERS = ('back/qbe/emit.bend', 'back/qbe/lower.bend', 'back/qbe/verify-direct.bend',
            'back/x86/program.bend', 'back/x86/function.bend', 'back/x86/stream.bend')


def same(a, b):
    return all(k in a and k in b and a[k] == b[k] for k in ('bytes', 'sha256'))


def document(path):
    identity = pin(path)
    return json.loads(verify(identity).read_text()), identity


def reference(report, case):
    require(report.get('complete') is True and report.get('passed') is True
            and not report.get('changedInputs') and report.get('target') == 'x86',
            'Complete independent x86 qualification required')
    rows = [r for r in report['rows'] if r['id'] == case]
    require(len(rows) == 1 and rows[0].get('status') == 'pass', 'One passed reference case required')
    row = rows[0]
    emitted = json.loads(verify(row['emission']).read_text())
    require(emitted.get('kind') == 'bend-build-request' and emitted.get('complete') is True
            and not emitted.get('changedInputs') and emitted.get('target') == 'x86'
            and same(emitted['source'], row['source']) and same(emitted['image'], report['image']),
            'Independent reference emission differs from qualification')
    verify(row['source']); verify(emitted['product'])
    return row, emitted


def observation(capture, analysis, attribution, events, binary):
    require(capture.get('complete') is True and capture.get('passed') is True
            and not capture.get('changedInputs'), 'Incomplete profiler capture')
    rows = capture.get('rows', [])
    require(len(rows) == 2 and [r['mode'] for r in rows] == ['clean', 'sample']
            and all(r.get('correct') is True for r in rows), 'Exactly one correct clean/sample pair required')
    quality = analysis['quality']
    require(analysis['header']['samples'] > 0 and all(quality.get(k) is True for k in
            ('zero_loss', 'handler_intact', 'main_thread_shutdown', 'delivery_plausible')),
            'Sampling delivery/integrity control failed; retain original quality limitations')
    binding = attribution.get('ownerBinding') or {}
    require(attribution.get('pairing', {}).get('verified') is True
            and binding.get('producerProvenanceVerified') is True
            and binding.get('checkedFids', 0) > 0 and binding.get('sourceMap'),
            'Actual capture/build/source-map/ELF owner binding required')
    require(len(events) == analysis['header']['samples'] == attribution['coverage']['allSamples'],
            'Attribution event count differs from actual capture')
    located = [e for e in events if e['leaf'].get('objectSha256') == binary['sha256']
               and e['leaf'].get('loweredOwner') and e['leaf'].get('sourceLocation')]
    require(located, 'No actual final-image sample has an exact mapped source owner')
    return dict(samples=len(events), mappedSourceOwnerSamples=len(located),
                distinctMappedOwners=sorted({e['leaf']['loweredOwner'] for e in located}),
                originalProfileUsable=analysis['usable'], quality=quality,
                checkedFids=binding['checkedFids'], capabilityOnly=True,
                quantitativeProfileAdmitted=False)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--assets', type=Path, default=PHASE / 'assets01.json')
    p.add_argument('--build-report', type=Path, default=PHASE / 'native-chain01/n2/report.json')
    p.add_argument('--source-map', type=Path, default=PHASE / 'source01/compiler.bend.map.json')
    p.add_argument('--source-root', type=Path, default=ROOT / 'selfhost')
    p.add_argument('--reference-report', type=Path, default=PHASE / 'seed-focused01/report.json')
    p.add_argument('--case', default='focused/lexer-scan')
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--seconds', type=float, default=60)
    p.add_argument('--cpu', type=int, default=3)
    p.add_argument('--guarded', action='store_true')
    a = p.parse_args()
    timeout(a.seconds)
    require(a.guarded and os.sched_getaffinity(0) == {a.cpu}, 'Run inside one outer guarded CPU lane')
    built, build_pin = document(a.build_report)
    qualified, reference_pin = document(a.reference_report)
    require(built.get('kind') == 'bend-native-build' and built.get('complete') is True
            and not built.get('changedInputs') and built.get('target') == 'x86'
            and built.get('runtimeABI') == 11102, 'Completed current x86 build required')
    row, emitted = reference(qualified, a.case)
    binary = built['binary']; verify(binary)
    require(not same(binary, emitted['image']), 'Reference must come from an independent compiler image')
    args = argparse.Namespace(workspace=ROOT, assets=a.assets, image_key=None,
        image=Path(binary['file']), image_receipt=a.build_report, source=Path(row['source']['file']),
        host='native', target='x86', stage='N2', mode='cache', base_key='base',
        carrier_key='prepared-base', engine_key='bun', out=a.out / 'request',
        seconds=a.seconds, expected=Path(emitted['product']['file']), plan=True)
    plan = request.plan(args)
    previous = emitted['request']
    require(plan['outputContract'] == 'stdout' and plan['runtimeArgumentConvention'] == 'bend-rts-v1'
            and all(same(plan[k], previous[k]) for k in ('source', 'base', 'carrier'))
            and plan['stamp'] == previous['stamp'] and plan['mode'] == previous['mode'],
            'Independent oracle must use the same source/Base/carrier/stamp/mode')
    emitters = [a.source_root / 'src' / name for name in EMITTERS]
    methods = [PROFILER / name for name in ('owners.py', 'attribute.py', 'build-sampler.py',
               'freeze.py', 'run.py', 'analyze.py', 'sample.c')]
    inputs = [pin(__file__), build_pin, reference_pin, row['emission'], pin(a.source_map),
              *map(pin, emitters), *map(pin, methods), *plan['inputs']]
    out = fresh_output(a.out, ROOT)
    started = time.monotonic()
    report = dict(kind='phase183-x86-profiler-controls', version=1, complete=False, passed=False,
        case=a.case, inputs=inputs, binary=binary, reference=reference_pin, rows=[],
        cpuAffinity=sorted(os.sched_getaffinity(0)), capabilityOnly=True,
        quantitativeProfileAdmitted=False,
        scope='Actual N2 clean/sampled complete-output equality against independent qualification; '
              'linked ELF FID pointers and exact maintained source locations. No performance ratio, '
              'statistical hotspot claim, physical callers, logical stack or dispatch instrumentation.')

    def save():
        report['seconds'] = time.monotonic() - started
        write_json(out / 'report.json', report)

    def invoke(name, command):
        left = a.seconds - (time.monotonic() - started)
        require(left > 0, 'Whole control deadline exceeded')
        job = dict(name=name, process=run([sys.executable, '-B', *map(str, command)], cwd=ROOT,
            stdout=out / (name + '.stdout'), stderr=out / (name + '.stderr'), seconds=left))
        report['rows'].append(job); save()
        require(job['process']['complete'], 'Maintained profiler stage failed: ' + name)

    save()
    try:
        write_json(out / 'request.json', plan)
        owner_args = [PROFILER / 'owners.py', '--assembly', verify(built['assembly']),
            '--build-receipt', a.build_report, '--source-map', a.source_map,
            '--source-root', a.source_root, '--output', out / 'owners.json']
        for path in emitters:
            owner_args += ['--emitter-source', path]
        invoke('owners', owner_args)
        owner_map, owner_pin = document(out / 'owners.json')
        inputs.extend(owner_map['sourceMap']['modules'])
        inputs.extend([owner_map['sourceMap']['source'], owner_map['buildProvenance']['assembly'],
                       owner_map['buildProvenance']['runtime'], owner_map['buildProvenance']['producerImage']])
        require(owner_map['descriptor']['magic'] == 11102, 'Expected current descriptor ABI')
        report['owners'] = owner_pin
        invoke('sampler', [PROFILER / 'build-sampler.py', '--out', out / 'sampler'])
        empty = out / 'empty.stderr'; empty.write_bytes(b'')
        recipe = dict(cwd=str(ROOT), sampler=str(out / 'sampler/sampler.so'), scope=report['scope'],
            inputs=list(dict.fromkeys(r['file'] for r in inputs)), workloads=[dict(name='compiler-request',
            timeoutSeconds=min(15, a.seconds), variants=[dict(name='x86-N2', command=plan['command'],
            runtimeArgumentConvention=plan['runtimeArgumentConvention'],
            stdout=emitted['product']['file'], stderr=str(empty))])])
        write_json(out / 'recipe.json', recipe)
        invoke('freeze', [PROFILER / 'freeze.py', '--recipe', out / 'recipe.json', '--out', out / 'workloads.json'])
        invoke('capture', [PROFILER / 'run.py', '--manifest', out / 'workloads.json',
            '--out', out / 'capture', '--modes', 'clean,sample', '--rounds', '1', '--periods-us', '8000'])
        capture, capture_pin = document(out / 'capture/report.json')
        samples = [r for r in capture['rows'] if r['mode'] == 'sample']
        require(len(samples) == 1, 'One actual sampled request required')
        analysis_path = verify(samples[0]['analysis'])
        invoke('attribute', [PROFILER / 'attribute.py', '--analysis', analysis_path,
            '--owners', out / 'owners.json', '--out', out / 'attribution'])
        attributed, attribution_pin = document(out / 'attribution/report.json')
        events = [json.loads(line) for line in verify(attributed['identities']['events']).read_text().splitlines()]
        report['observation'] = observation(capture, json.loads(analysis_path.read_text()), attributed, events, binary)
        report.update(capture=capture_pin, attribution=attribution_pin, complete=True, passed=True)
    except Exception as error:
        report['error'] = repr(error)
    finally:
        report['changedInputs'] = changed_inputs(inputs)
        if report['changedInputs']:
            report.update(complete=False, passed=False)
        save()
    print(json.dumps({k: report.get(k) for k in ('complete', 'passed', 'seconds', 'observation', 'error')}))
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    sys.exit(main())
