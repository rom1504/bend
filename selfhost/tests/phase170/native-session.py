#!/usr/bin/env python3
"""Qualify native P140/2 before advertising it; run inside one caller-owned guard."""
import argparse
import copy
import hashlib
import json
import os
from pathlib import Path
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
BUILD = ROOT / 'selfhost/tools/build'
sys.path.insert(0, str(BUILD))
import assets
import common
import native
import request
from common import changed_inputs, fresh_output, pin, require, run, same_bytes, verify, write_json
sys.path.insert(0, str(BUILD / 'session'))
import transport

NAMES = ['cold-a', 'noop-a', 'edit-b', 'revert-a', 'recover-b', 'recover-a']
VARIANTS = ['a', 'a', 'b', 'a', 'b', 'a']
# Independent literal fixtures, not values inferred from generated output.
ORIGINAL = ('import Base\ndef work(x: U32) -> U32:\n'
            '  U32.add(x, 1)\ndef main() -> U32:\n  work(2)\n')
SOURCES = {'a': ORIGINAL, 'b': ORIGINAL.replace('U32.add(x, 1)', 'U32.add(x, 3)')}
ORACLES = {'a': '3\n', 'b': '5\n'}


def identity(row):
    return {key: row[key] for key in ('bytes', 'sha256')}


def qualify(a):
    root = common.workspace(a.workspace)
    common.clean_environment()
    common.timeout(a.seconds)
    document = assets.load_assets(a.assets, root)
    a.host, a.stage, a.target, a.image_key = 'native', 'N2', 'qbe', None
    image, metadata, image_inputs = request.image_binding(a, document)
    construction = json.loads(Path(a.image_receipt).read_text())
    require(construction.get('kind') == 'bend-native-build' and not construction.get('error')
            and not construction.get('changedInputs') and identity(construction['binary']) == identity(image),
            'Actual successful maintained N2 construction receipt required')
    require(os.access(image['file'], os.X_OK), 'Executable N2 image required')
    require(metadata.get('protocol') == 'qbe-source-v1', 'Actual ordinary QBE N2 binding required')
    source = pin(a.source)
    require(identity(source) == identity(metadata['sourceIdentity']), 'Compiler source differs from actual N2 lineage')
    linked_runtime = metadata['linkedRuntime']
    verify(linked_runtime)
    base, carrier, stamp, base_inputs = assets.prepared_base(document, 'cache')
    runtime = assets.asset(document, a.runtime_key)
    jobs_pin = pin(a.jobs)
    job_doc = json.loads(Path(jobs_pin['file']).read_text())
    require(job_doc.get('kind') == 'bend-session-jobs' and job_doc.get('version') == 1,
            'Maintained session job manifest required')
    jobs = job_doc['jobs']
    require(isinstance(jobs, list) and len(jobs) == 6 and [j['name'] for j in jobs] == NAMES,
            'Exactly the six maintained positive native jobs are required')
    logical = job_doc['logical']
    require(Path(logical).is_absolute() and not any(c in logical for c in '\r\n'), 'Absolute logical path required')
    inputs = [document['_manifest'], source, linked_runtime, jobs_pin, *image_inputs,
              *base_inputs, runtime, pin(__file__), pin(sys.executable),
              *[pin(m.__file__) for m in (assets, common, native, request, transport)]]
    prepared = []
    hint = len(ORIGINAL[:ORIGINAL.index('U32.add')].encode('utf-16-le')) // 2
    for i, (job, variant) in enumerate(zip(jobs, VARIANTS)):
        source_pin = pin(job['source'])
        require(Path(source_pin['file']).read_bytes() == SOURCES[variant].encode(), 'Fixture differs from independent oracle')
        require(job.get('expectError') is False and job['owner'] == 'work'
                and type(job['hint']) is int and job['hint'] == hint
                and job['mode'] == ('cold' if i == 0 else 'warm'), 'Native positive fixture contract differs')
        row = dict(job, source=source_pin, variant=variant)
        inputs.append(source_pin)
        if job.get('expected'):
            row['expected'] = pin(job['expected'])
            inputs.append(row['expected'])
        prepared.append(row)
    plan = dict(kind='phase170-native-session-bootstrap-plan', version=1,
                protocolUnderTest='P140/2', image=image, source=source,
                originalBinding=metadata, base=base, carrier=carrier, stamp=stamp,
                linkedRuntime=linked_runtime, targetRuntime=runtime, logical=logical,
                jobs=prepared, inputs=inputs, maxJobsPerBatch=6,
                referencePolicy='Two fresh cold incremental requests; ordinary cold compilation is not the reference.')
    if a.plan:
        return dict(plan, targetsRun=False)
    out = fresh_output(a.out, root)
    write_json(out / 'plan.json', plan)
    report = dict(kind='bend-native-session-bootstrap-qualification', version=1,
                  complete=False, passed=False, qualified=False, protocolUnderTest='P140/2',
                  image=image, source=source, linkedRuntime=linked_runtime, targetRuntime=runtime,
                  originalImageReceipt=pin(a.image_receipt), inputs=inputs, batches=[], builds=[],
                  scope='Six positive native byte-session jobs; same-mode cold equality and independent A/B execution. '
                        'No native error recovery, object units, general invalidation theorem, performance or installed selection claim.')
    started = time.monotonic()

    def save():
        report['seconds'] = time.monotonic() - started
        write_json(out / 'report.json', report)

    def left():
        remaining = a.seconds - (time.monotonic() - started)
        require(remaining > 0, 'Whole qualification deadline exceeded')
        return remaining

    def batch(name, rows):
        require(0 < len(rows) <= 6, 'At most six jobs per native batch')
        directory = out / name
        directory.mkdir()
        lines = []
        for i, row in enumerate(rows):
            fields = [row['source']['file'], str(directory / f'{i:03}.frames'),
                      str(row['hint']), row['owner'], row['mode']]
            require(not any('\n' in f or '\r' in f for f in fields), 'Record separator in job field')
            lines.extend(fields)
        job_file = directory / 'jobs.txt'
        job_file.write_text('\n'.join(lines) + '\n')
        inputs.append(pin(job_file))
        command = [image['file'], '--threads', '1', '--gpu', 'off', '--',
                   'phase140-batch', logical, base['file'], carrier['file'], stamp, str(job_file), 'v1']
        result = dict(name=name, complete=False, protocolUnderTest='P140/2', rows=[])
        report['batches'].append(result)
        result['process'] = run(command, cwd=root, stdout=directory / 'stdout',
                                stderr=directory / 'stderr', seconds=left())
        save()
        require(result['process']['complete'] and result['process']['stderr']['bytes'] == 0,
                'Native batch producer failed or emitted diagnostics')
        prior = None
        for i, row in enumerate(rows):
            context = dict(kind='phase140-transport-context', protocol=2,
                           session=hashlib.sha256(str(directory).encode()).hexdigest(),
                           producer=image, runtime=runtime, source=row['source'],
                           policy=dict(kind='cached-session-v1', logicalSourcePath=logical), inputs=inputs)
            context_file = directory / f'{i:03}-context.json'
            write_json(context_file, context)
            with (directory / f'{i:03}.frames').open('rb') as stream:
                decoded = transport.decode(stream, directory / f'{i:03}-transport', context_file,
                    pin(context_file)['sha256'], prior, pin(prior)['sha256'] if prior else None,
                    row.get('expected', {}).get('sha256'))
            prior = directory / f'{i:03}-transport/report.json'
            result['rows'].append(dict(name=row['name'], variant=row['variant'], source=row['source'],
                product=decoded['payload'], transport=pin(prior), reusedPieces=decoded['reusedPieces']))
        result.update(complete=True, producerSuccessJoined=True)
        save()
        return result['rows']

    save()
    try:
        observed = batch('positive', prepared)
        # Two cold requests cover the two unique snapshots without rerunning six clones.
        references = batch('cold-reference', [dict(prepared[i], name='cold-' + prepared[i]['variant'], mode='cold') for i in (0, 2)])
        by_variant = {row['variant']: row for row in references}
        for row in observed:
            expected = by_variant[row['variant']]['product']
            require(identity(row['product']) == identity(expected)
                    and same_bytes(row['product']['file'], expected['file']), 'Warm/cold incremental product mismatch')
            row['modeMatchedColdExact'] = True
        require(identity(by_variant['a']['product']) != identity(by_variant['b']['product']), 'Real edit did not change QBE')
        require(observed[1]['reusedPieces'] > 0, 'No-op did not exercise native transport reuse')
        report.update(modeMatchedColdComparisons=6, realEditChangesProduct=True, noOpExercisesReuse=True)
        for variant in ('a', 'b'):
            oracle = out / (variant + '.expected.stdout')
            oracle.write_text(ORACLES[variant])
            inputs.append(pin(oracle))
            parser = argparse.ArgumentParser(add_help=False)
            request.arguments(parser, source_required=False)
            build_args = parser.parse_args(['--assets', str(a.assets), '--out', str(out / ('build-' + variant))])
            build_args.workspace, build_args.seconds = root, left()
            build_args.ir = Path(by_variant[variant]['product']['file'])
            build_args.runtime_key, build_args.runtime = a.runtime_key, None
            build_args.retain_ir, build_args.expected_stdout = False, oracle
            build_args.output_stage, build_args.output_protocol = None, 'qbe-source-v1'
            built = native.build(build_args)
            report['builds'].append(dict(variant=variant, report=pin(build_args.out / 'report.json')))
            require(built.get('complete') is True and built.get('outputExact') is True,
                    'Independent generated-program execution failed: ' + variant)
            inputs.extend(built['inputs'])
        report['changedInputs'] = changed_inputs(inputs)
        require(not report['changedInputs'], 'Compiler source or another input changed during qualification')
        report.update(sourceAfter=pin(source['file']), sourceUnchanged=True)
        report.update(complete=True, passed=True, qualified=True, generatedProgramOutputs=ORACLES)
        save()
        # This new binding is written only after the complete independent gate exists.
        qualification = pin(out / 'report.json')
        binding = copy.deepcopy(metadata)
        binding['sessionProtocols'] = sorted(set(binding.get('sessionProtocols', []) + ['P140/2']))
        binding['sessionQualification'] = qualification
        binding['sessionScope'] = 'Successful native P140/2 byte batches only; no error recovery or object units.'
        write_json(out / 'image-binding.json', binding)
        return dict(complete=True, passed=True, qualification=qualification,
                    imageBinding=pin(out / 'image-binding.json'), seconds=report['seconds'])
    except BaseException as error:
        report.update(complete=False, passed=False, qualified=False, error=repr(error), changedInputs=changed_inputs(inputs))
        save()
        return report


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--workspace', type=Path)
    for name in ('assets', 'image', 'image-receipt', 'source', 'jobs', 'out'):
        p.add_argument('--' + name, type=Path, required=True)
    p.add_argument('--runtime-key', default='qbe-runtime')
    p.add_argument('--seconds', type=float, default=120)
    p.add_argument('--plan', action='store_true')
    a = p.parse_args()
    result = qualify(a)
    print(json.dumps(result if a.plan else {k: result.get(k) for k in ('complete', 'passed', 'error', 'qualification', 'imageBinding', 'seconds')}, indent=2))
    return 0 if a.plan or result.get('passed') is True else 1


if __name__ == '__main__':
    sys.exit(main())
