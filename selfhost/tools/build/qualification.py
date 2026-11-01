#!/usr/bin/env python3
"""Finite source/output qualification across explicit compiler hosts and targets.

Run under one outer build-retention guard. No historical implementation imports.
"""
import argparse
import copy
import json
from pathlib import Path
import sys
import time

sys.dont_write_bytecode = True
import assets
import native
import request
from common import (changed_inputs, fresh_output, pin, require, run, timeout,
                    verify, workspace, write_json)

UPSTREAM = '059266225b77c8ca256ac6b25ee5c21449bab151'
CATALOG = Path(__file__).parents[1] / 'conformance/qualification-catalog.json'


def bound(row, root):
    result = dict(row, file=str((root / row['file']).resolve()))
    verify(result)
    return result


def output_exact(child, expected):
    """No trimming, exit normalization, or timeout/crash-as-rejection."""
    return (child.get('started') is not None and not child.get('timedOut')
            and not child.get('error') and child.get('exitCode') == expected['exitCode']
            and verify(child['stdout']).read_bytes() == expected['stdout'].encode()
            and verify(child['stderr']).read_bytes() == expected['stderr'].encode())


def refusal(case, emission, hosted=None):
    process = emission.get('process', {})
    closed = (process.get('started') is not None and process.get('exitCode') == 1
              and not process.get('timedOut') and not process.get('error'))
    empty = process.get('stdout', {}).get('bytes') == 0 and emission.get('product', {}).get('bytes', 0) == 0
    clean = not emission.get('changedInputs')
    if not (closed and empty and clean):
        return False
    target, host = emission['target'], emission['host']
    if target == 'qbe':
        rule = case['refusal']
        if host == 'native':
            diagnostic = verify(process['stderr']).read_text()
        else:
            if not hosted or hosted.get('kind') != 'bend-hosted-request' or hosted.get('complete') is not False:
                return False
            observation = hosted.get('observation', {})
            if observation.get('status') != 'error':
                return False
            diagnostic = observation.get('diagnostic', '')
        # The prefixes are the native compiler's stage protocol, not inferred
        # from namespace names or a generic nonzero child status.
        prefix = rule['prefix']
        return (diagnostic in (prefix, prefix + '\n') if rule['exact'] else
                diagnostic.startswith(prefix) and bool(diagnostic[len(prefix):].strip()))
    if host == 'js' and case['name'] in ('negative-type', 'negative-affine'):
        observation = (hosted or {}).get('observation', {})
        return (bool(hosted) and hosted.get('kind') == 'bend-hosted-request' and hosted.get('complete') is False
                and observation.get('status') == 'error' and observation.get('phase') == 'check'
                and observation.get('checked') is True and observation.get('typeAccepted') is not True
                and bool(observation.get('diagnostic')))
    return False


def supported(case, args):
    if 'refusal' not in case or args.target == 'qbe':
        return True
    return args.host == 'js' and case['name'] in ('negative-type', 'negative-affine')


def verify_hosted(emission, hosted, request_file):
    """A language refusal still has to preserve its complete host closure."""
    require(hosted.get('kind') == 'bend-hosted-request' and hosted.get('version') == 1,
            'Expected structured hosted request receipt')
    require(hosted.get('target') == emission['target'] and hosted.get('stage') == emission['stage'],
            'Hosted target/stage differ from executing request')
    require(hosted.get('request') == pin(request_file), 'Hosted request identity differs')
    for key in ('image', 'source'):
        require(hosted.get(key) == emission[key], 'Hosted ' + key + ' differs')
    require(isinstance(hosted.get('inputs'), list) and hosted['inputs']
            and not hosted.get('changedInputs'), 'Hosted input closure missing or changed')
    for row in hosted['inputs']:
        verify(row)


def select(args, root):
    catalog = json.loads(CATALOG.read_text())
    require(catalog['kind'] == 'bend-qualification-catalog' and catalog['version'] == 1
            and catalog['upstream'] == UPSTREAM, 'Unknown qualification catalog')
    selected = [copy.deepcopy(c) for c in catalog['cases']
                if args.suite == 'all' or c['suite'] == args.suite]
    if args.case:
        wanted = set(args.case)
        selected = [c for c in selected if c['id'] in wanted or c['name'] in wanted]
        require(wanted <= {v for c in selected for v in (c['id'], c['name'])}, 'Unknown case selection')
    require(selected, 'Empty qualification selection')
    inputs = [pin(CATALOG)]
    for case in selected:
        case['source'] = bound(case['source'], root)
        inputs.append(case['source'])
        if 'stdoutFile' in case:
            case['stdoutFile'] = bound(case['stdoutFile'], root)
            require(verify(case['stdoutFile']).read_bytes() == case['expect']['stdout'].encode(),
                    'Oracle text/file differ: ' + case['id'])
            inputs.append(case['stdoutFile'])
    return selected, inputs


def execute_case(args, case, document, out, root):
    row = dict(id=case['id'], source=case['source'], expected=case['expect'], status='pending')
    if not supported(case, args):
        row.update(status='unsupported', reason='No independent refusal oracle for this host/target protocol')
        return row
    out.mkdir()
    emit_args = copy.copy(args)
    emit_args.source, emit_args.out = Path(case['source']['file']), out / 'emission'
    emission = request.execute(emit_args)
    row['emission'] = pin(emit_args.out / 'report.json')
    hosted = None
    if args.host == 'js':
        hosted_file = emit_args.out / 'hosted.json'
        require(hosted_file.is_file(), 'Hosted child did not retain its structured observation')
        hosted = json.loads(hosted_file.read_text())
        row['hostedObservation'] = pin(hosted_file)
        verify_hosted(emission, hosted, emit_args.out / 'request.json')
    if 'refusal' in case:
        row.update(status='pass' if refusal(case, emission, hosted) else 'fail',
                   expectedStage=case['refusal']['phase'] if args.target == 'qbe' else 'check',
                   rule=case['refusal'] if args.target == 'qbe' else 'Checked frontend refusal')
        return row
    if not emission['complete']:
        row.update(status='fail', failedStage='emission')
        return row
    product = emission['product']
    if args.target == 'qbe':
        build_args = copy.copy(args)
        build_args.ir, build_args.out = Path(product['file']), out / 'build'
        build_args.source = build_args.image = build_args.image_key = build_args.runtime = None
        build_args.retain_ir, build_args.expected_stdout = True, Path(case['stdoutFile']['file'])
        build_args.output_stage, build_args.output_protocol = None, 'qbe-source-v1'
        build_args.seconds = args.build_seconds + args.execute_seconds
        built = native.build(build_args)
        row['build'] = pin(build_args.out / 'report.json')
        executions = [job for job in built['jobs'] if job['label'] == 'execute']
        row.update(status='pass' if built['complete'] and len(executions) == 1
                   and output_exact(executions[0], case['expect']) else 'fail')
        return row
    if args.target == 'js':
        engine = assets.asset(document, args.program_engine_key)
        row['programEngine'] = engine
        command = [engine['file'], product['file']]
    else:
        policy = document.get('toolchains', {}).get('c')
        require(isinstance(policy, dict) and all(k in policy for k in ('compiler', 'flags', 'libraries')),
                'Explicit C construction policy required')
        compiler = assets.asset(document, policy['compiler'])
        binary = out / 'program'
        command = [compiler['file'], *policy['flags'], *policy.get('includeFlags', []),
                   product['file'], '-o', str(binary), *policy['libraries']]
        built = run(command, cwd=root, stdout=out / 'build.stdout', stderr=out / 'build.stderr', seconds=args.build_seconds)
        row.update(toolchain=policy, compiler=compiler, buildProcess=built)
        if not built['complete'] or not binary.is_file():
            row.update(status='fail', failedStage='machine-build')
            return row
        row['binary'] = pin(binary)
        command = [str(binary), '--threads', '1', '--gpu', 'off']
    child = run(command, cwd=out, stdout=out / 'execute.stdout', stderr=out / 'execute.stderr', seconds=args.execute_seconds)
    row.update(execution=child, status='pass' if output_exact(child, case['expect']) else 'fail')
    return row


def qualify(args):
    root = workspace(args.workspace)
    require(args.host and args.stage and (args.image_key or args.image), 'Explicit executing host, stage and image required')
    require(not args.source and not args.expected, 'Catalog owns sources and output oracles')
    timeout(args.build_seconds); timeout(args.execute_seconds)
    document = assets.load_assets(args.assets, root)
    require(document.get('upstream') == UPSTREAM, 'Asset/reference upstream differs from catalog')
    cases, inputs = select(args, root)
    inputs += [pin(__file__), pin(request.__file__), pin(native.__file__), pin(assets.__file__),
               pin(Path(__file__).with_name('common.py')), document['_manifest']]
    # Authenticate the image/Base/protocol even for plan mode and unsupported-only selections.
    first = copy.copy(args)
    first.source, first.out = Path(cases[0]['source']['file']), args.out / 'preflight'
    preflight = request.plan(first)
    inputs += preflight['inputs']
    for key in ([args.program_engine_key] if args.target == 'js' else
                ['qbe', 'assembler', 'linker', args.runtime_key] if args.target == 'qbe' else
                [document['toolchains']['c']['compiler']]):
        inputs.append(assets.asset(document, key))
    report = dict(kind='bend-finite-qualification', version=1, complete=False, passed=False,
                  fullConformance=False, upstream=UPSTREAM, host=args.host, target=args.target,
                  stage=args.stage, mode=args.mode, image=preflight['image'], inputs=inputs,
                  selected=[c['id'] for c in cases], rows=[],
                  scope='Focused19/broad45 regression sources with retained independent whole-output oracles. '
                        'No performance, kernel-proof, unrestricted-provider, GPU or multi-mutator qualification.',
                  unsupportedPolicy='Unsupported is retained and prevents passed=true; it is never a pass.',
                  historicalPolicy='Historical catalog fields are provenance only; no historical file is read.')
    if args.plan:
        report['planOnly'] = True
        report['supported'] = [c['id'] for c in cases if supported(c, args)]
        return report
    out = fresh_output(args.out, root)
    start = time.monotonic()
    write_json(out / 'report.json', report)
    try:
        for index, case in enumerate(cases):
            try:
                row = execute_case(args, case, document, out / ('%02d-' % index + case['name']), root)
            except Exception as error:
                row = dict(id=case['id'], status='fail', error=repr(error))
            report['rows'].append(row)
            write_json(out / 'report.json', report)
        report['complete'] = len(report['rows']) == len(cases)
    finally:
        report['changedInputs'] = changed_inputs(inputs)
        report['counts'] = {s: sum(r['status'] == s for r in report['rows']) for s in ('pass', 'fail', 'unsupported')}
        report['passed'] = report['complete'] and not report['changedInputs'] and report['counts']['pass'] == len(cases)
        report['seconds'] = time.monotonic() - start
        write_json(out / 'report.json', report)
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    request.arguments(parser, source_required=False)
    parser.add_argument('--suite', choices=['focused', 'broad', 'all'], default='focused')
    parser.add_argument('--case', action='append')
    parser.add_argument('--program-engine-key', default='bun')
    parser.add_argument('--runtime-key', default='qbe-runtime')
    parser.add_argument('--build-seconds', type=float, default=90)
    parser.add_argument('--execute-seconds', type=float, default=20)
    args = parser.parse_args()
    result = qualify(args)
    print(json.dumps(result if args.plan else {k: result[k] for k in ('complete', 'passed', 'counts', 'seconds')}, indent=2))
    return 0 if args.plan or result['passed'] else 1


if __name__ == '__main__':
    sys.exit(main())
