#!/usr/bin/env python3
"""Build QBE, x86 assembly, or opt-in x86 objects with explicit toolchain/runtime assets."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import selectors
import shutil
import subprocess
import sys
import time

sys.dont_write_bytecode = True
import assets
import request as requests
from common import (changed_inputs, clean_environment, fresh_output, kill, pin,
                    require, run, same_bytes, timeout, verify, workspace, write_json)


def derived_protocol(target, explicit=None):
    # An explicit protocol describes the compiled compiler's entry contract,
    # which can differ from the seed's machine target (e.g. QBE builds x86 N0).
    return explicit or {'qbe':'qbe-source-v1', 'x86':'native-x86-source-v1'}[target]


def build(args):
    root = workspace(args.workspace)
    clean_environment()
    timeout(args.seconds)
    require(args.target in ('qbe', 'x86'), 'Native pipeline accepts QBE or x86 assembly')
    object_output = requests.object_emission(args)
    output_protocol = derived_protocol(args.target, getattr(args, 'output_protocol', None))
    document = assets.load_assets(args.assets, root)
    tools = {key: assets.asset(document, key) for key in
             (('linker',) if object_output else
              ('qbe', 'assembler', 'linker') if args.target == 'qbe' else ('assembler', 'linker'))}
    runtime = pin(args.runtime) if args.runtime else assets.asset(document, args.runtime_key)
    policy = document.get('runtimePolicies', {}).get(args.runtime_key) if not args.runtime else None
    argument_provider = assets.runtime_provider(document, args.runtime_key) if not args.runtime else None
    explicit_convention = getattr(args, 'runtime_argument_convention', None)
    if explicit_convention is not None:
        require(args.runtime is not None, '--runtime-argument-convention requires explicit --runtime')
        argument_provider = dict(runtimeArgumentConvention=explicit_convention)
    explicit_abi = getattr(args, 'runtime_abi', None)
    if explicit_abi is not None:
        require(args.runtime is not None, '--runtime-abi requires explicit --runtime')
        argument_provider = dict(argument_provider or {}, runtimeABI=explicit_abi)
    convention = assets.runtime_argument_convention(argument_provider)
    runtime_abi = assets.runtime_abi(argument_provider)
    if args.target == 'x86':
        require(runtime_abi == 11102, 'x86 requires an explicitly bound runtimeABI 11102')
    toolchain = assets.native_toolchain(document, args.target)
    if args.ir:
        require(not args.source and not args.image and not args.image_key,
                '--ir cannot be combined with a compiler request')
        source_ir, request = pin(args.ir), None
        inputs = [source_ir]
        if object_output:
            requests.x86_object_header(source_ir['file'])
    else:
        require(args.source and args.host and args.stage and (args.image or args.image_key),
                'Supply a complete compiler request or --ir')
        request = requests.plan(args)
        require(request['outputContract'] == 'stdout', 'Pipeline requires complete stdout emission')
        source_ir, inputs = None, list(request['inputs'])
    expected = pin(args.expected) if args.expected else None
    expected_stdout = pin(args.expected_stdout) if args.expected_stdout else None
    inputs += [document['_manifest'], pin(__file__), pin(assets.__file__),
               pin(requests.__file__), pin(Path(__file__).with_name('common.py')),
               pin(sys.executable), runtime, *tools.values()]
    inputs += [p for p in (expected, expected_stdout) if p]
    for row in inputs:
        verify(row)
    out = args.out.resolve()
    qcmd = ([tools['qbe']['file'], '-t', toolchain['target'], '-o', str(out / 'program.s'),
             source_ir['file'] if source_ir else '-'] if args.target == 'qbe' else None)
    digest_key = 'objectDigest' if object_output else 'irDigest' if args.target == 'qbe' else 'assemblyDigest'
    report = dict(kind='bend-native-build', version=1, complete=False, inputs=inputs,
                  host=request['host'] if request else None, target=args.target,
                  stage=request['stage'] if request else None,
                  request=request, sourceIR=source_ir, runtime=runtime,
                  runtimePolicy=policy or 'Explicit caller-supplied object; policy is not inferred.',
                  runtimeArgumentConvention=convention,
                  compilerCommand=request['command'] if request else None, qbeCommand=qcmd,
                  toolchain=toolchain, jobs=[], retainIR=args.retain_ir,
                  expectedQbe=expected, expectedStdout=expected_stdout,
                  comparedToReference=False, relayLimitBytes=65536, maximumRelayBytes=0,
                  machineDiagnosticPolicy='Assembler/linker warnings retained on zero exit; compiler/QBE/execution stderr fails.',
                  scope='Host transport and machine construction. No compiler semantics, stage promotion or installed selection change.',
                  timingScope='Whole emission/machine pipeline after preflight, under one outer disk/process guard.')
    if runtime_abi is not None:
        report['runtimeABI'] = runtime_abi
    if args.target == 'x86':
        report['sourceObject' if object_output else 'sourceAssembly'] = report.pop('sourceIR')
        report['expectedObject' if object_output else 'expectedAssembly'] = report.pop('expectedQbe')
        report.pop('qbeCommand')
        report['relayLimitBytes'] = 0
        report['machineDiagnosticPolicy'] = 'Assembler/linker warnings retained on zero exit; compiler/execution stderr fails.'
    if object_output:
        report['emissionFormat'] = requests.X86_OBJECT_FORMAT
        report['assemblerSkipped'] = True
        report['objectPolicy'] = 'Bend-emitted ELF object bytes; declared assemblerFlags are not applied. Linker/runtime policy is unchanged.'
        report['machineDiagnosticPolicy'] = 'Linker warnings retained on zero exit; compiler/execution stderr fails. No assembler executes.'
    if args.plan:
        return report
    fresh_output(out, root)
    if request:
        write_json(out / 'request.json', request)
    start, children = time.monotonic(), []
    deadline = start + args.seconds
    retained, selector = None, selectors.DefaultSelector()

    def save():
        report['wallSeconds'] = time.monotonic() - start
        write_json(out / 'report.json', report)

    def left():
        seconds = deadline - time.monotonic()
        if seconds <= 0:
            raise TimeoutError('Whole pipeline deadline exceeded')
        return seconds

    def stage(label, command, stdout=None):
        result = run(command, cwd=root, stdout=stdout or out / (label + '.stdout'),
                     stderr=out / (label + '.stderr'), seconds=left())
        result['label'] = label
        report['jobs'].append(result)
        if result.get('timedOut'):
            raise TimeoutError(label + ' exceeded pipeline deadline')
        save()
        require(result['complete'] and (label in ('assemble', 'link')
                or result['stderr']['bytes'] == 0), label + ' failed or emitted unexpected diagnostics')
        return result

    save()
    try:
        if args.target == 'x86':
            emitted_path = out / ('program.o' if object_output else 'program.s')
            emitted_kind = 'object' if object_output else 'assembly'
            if source_ir:
                require(source_ir['bytes'] > 0, 'Empty supplied ' + emitted_kind)
                shutil.copyfile(verify(source_ir), emitted_path)
            else:
                emitted = stage('compiler', request['command'], stdout=emitted_path)
                report['compilerExitCode'] = emitted['exitCode']
                report['compilerStderr'] = emitted['stderr']
            product = pin(emitted_path)
            require(product['bytes'] > 0, 'Empty emitted ' + emitted_kind)
            if source_ir:
                require(all(product[k] == source_ir[k] for k in ('bytes', 'sha256')),
                        'Supplied ' + emitted_kind + ' copy differs')
            if object_output:
                report['objectHeader'] = requests.x86_object_header(emitted_path)
            report[digest_key] = {k: product[k] for k in ('bytes', 'sha256')}
            if args.retain_ir:
                report['retainedObject' if object_output else 'retainedAssembly'] = product
        elif source_ir:
            require(source_ir['bytes'] > 0, 'Empty supplied QBE')
            stage('qbe', qcmd)
            report['irDigest'] = {k: source_ir[k] for k in ('bytes', 'sha256')}
        else:
            with (out / 'compiler.stderr').open('xb') as ce, (out / 'qbe.stderr').open('xb') as qe, (out / 'qbe.stdout').open('xb') as qo:
                consumer = subprocess.Popen(qcmd, cwd=root, stdin=subprocess.PIPE, stdout=qo,
                                            stderr=qe, bufsize=0, start_new_session=True)
                children.append(consumer)
                producer = subprocess.Popen(request['command'], cwd=root, stdout=subprocess.PIPE,
                                            stderr=ce, bufsize=0, start_new_session=True)
                children.append(producer)
                os.set_blocking(producer.stdout.fileno(), False)
                os.set_blocking(consumer.stdin.fileno(), False)
                selector.register(producer.stdout, selectors.EVENT_READ, 'read')
                buffer, pending, offset, eof = bytearray(65536), 0, 0, False
                view, digest, size = memoryview(buffer), hashlib.sha256(), 0
                if args.retain_ir:
                    retained = (out / 'program.ssa').open('xb')
                while not eof or pending:
                    remaining = left()
                    require(consumer.poll() is None, 'QBE exited before complete producer EOF')
                    for key, _ in selector.select(min(remaining, .25)):
                        if key.data == 'read':
                            count = producer.stdout.readinto(buffer)
                            if count is None:
                                continue
                            if count == 0:
                                eof = True
                                selector.unregister(producer.stdout)
                                producer.stdout.close()
                                consumer.stdin.close()
                            else:
                                digest.update(view[:count])
                                size += count
                                if retained:
                                    retained.write(view[:count])
                                pending, offset = count, 0
                                report['maximumRelayBytes'] = max(report['maximumRelayBytes'], count)
                                selector.unregister(producer.stdout)
                                selector.register(consumer.stdin, selectors.EVENT_WRITE, 'write')
                        else:
                            try:
                                count = os.write(consumer.stdin.fileno(), view[offset:pending])
                            except BlockingIOError:
                                continue
                            require(count > 0, 'Zero pipe write')
                            offset += count
                            if offset == pending:
                                pending, offset = 0, 0
                                selector.unregister(consumer.stdin)
                                selector.register(producer.stdout, selectors.EVENT_READ, 'read')
                report['compilerExitCode'] = producer.wait(timeout=left())
                report['qbeExitCode'] = consumer.wait(timeout=left())
                report['irDigest'] = dict(bytes=size, sha256=digest.hexdigest())
            if retained:
                retained.close()
                retained = None
                report['retainedIR'] = pin(out / 'program.ssa')
            for key, name in [('compilerStderr', 'compiler.stderr'), ('qbeStderr', 'qbe.stderr'), ('qbeStdout', 'qbe.stdout')]:
                report[key] = pin(out / name)
            require(report['compilerExitCode'] == report['qbeExitCode'] == 0,
                    'Compiler or QBE exited unsuccessfully')
            require(size > 0 and not any(report[key]['bytes'] for key in
                    ('compilerStderr', 'qbeStderr', 'qbeStdout')), 'Empty IR or unexpected compiler/QBE output')
            if request['host'] == 'js':
                hosted = json.loads((out / 'hosted.json').read_text())
                require(hosted.get('complete') is True, 'Hosted emission incomplete')
                report['hostedReport'] = pin(out / 'hosted.json')
        report['emitAndQbeSeconds' if args.target == 'qbe' else 'emissionSeconds'] = time.monotonic() - start
        if expected:
            require(report[digest_key] == {k: expected[k] for k in ('bytes', 'sha256')},
                    'Complete '+('object' if object_output else 'QBE' if args.target == 'qbe' else 'assembly')+' digest differs from independent reference')
            report['comparedToReference'] = True
        if not object_output:
            report['assembly'] = pin(out / 'program.s')
            stage('assemble', [tools['assembler']['file'], *toolchain['assemblerFlags'],
                              '-o', out / 'program.o', out / 'program.s'])
        stage('link', [tools['linker']['file'], *toolchain['linkerFlags'], out / 'program.o',
                      runtime['file'], *toolchain['libraries'], '-o', out / 'program'])
        report['object'], report['binary'] = pin(out / 'program.o'), pin(out / 'program')
        if expected_stdout:
            require(convention != 'bend-rts-v1' or 'BENDRTS' not in os.environ,
                    'Explicit RTS execution requires ambient BENDRTS to be unset')
            stage('execute', [out / 'program', *assets.runtime_arguments(argument_provider)])
            require(same_bytes(out / 'execute.stdout', expected_stdout['file']),
                    'Independent complete execution output differs')
            report['outputExact'] = True
        if args.output_stage:
            require(request is not None and args.output_stage.startswith('N'),
                    'Derived compiler binding requires an actual source producer and native N stage')
            report['imageBinding'] = dict(kind='bend-build-image-binding', version=1, complete=True,
                image=report['binary'], sourceIdentity=request['source'], host='native',
                stage=args.output_stage, protocol=output_protocol,
                targets={'native-c-source-v1':['c'], 'native-x86-source-v1':['x86'], 'qbe-source-v1':['qbe']}[output_protocol],
                linkedRuntime=runtime, runtimeArgumentConvention=convention,
                producer=request['image'], producerHost=request['host'],
                producerStage=request['stage'], qualification='Built; semantic/self-host qualification is separate.')
            if output_protocol == 'native-c-source-v1':
                report['imageBinding']['argvSentinel'] = 'compiler'
            if object_output:
                report['imageBinding']['producerEmissionFormat'] = requests.X86_OBJECT_FORMAT
            if runtime_abi is not None:
                report['imageBinding']['linkedRuntimeABI'] = runtime_abi
        require(args.retain_ir or not (out / 'program.ssa').exists(), 'Unexpected retained IR')
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
        report['timedOut'] = isinstance(error, (TimeoutError, subprocess.TimeoutExpired))
        for child in children:
            kill(child)
    finally:
        if retained:
            retained.close()
        selector.close()
        for child in children:
            for stream in (child.stdin, child.stdout, child.stderr):
                if stream is not None and not stream.closed:
                    stream.close()
        report['processes'] = [dict(pid=p.pid, status=p.poll(), command=p.args) for p in children]
        report['changedInputs'] = changed_inputs(inputs)
        if report['changedInputs']:
            report['complete'] = False
        if not report['complete'] and report.get('imageBinding'):
            report['imageBinding']['complete'] = False
        for key, name in [('compilerStderr', 'compiler.stderr'), ('qbeStderr', 'qbe.stderr')]:
            if (out / name).is_file():
                report[key] = pin(out / name)
        if args.target == 'x86':
            emitted_path = out / ('program.o' if object_output else 'program.s')
            if emitted_path.is_file():
                report['object' if object_output else 'assembly'] = pin(emitted_path)
        save()
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    requests.arguments(parser, source_required=False)
    parser.add_argument('--ir', type=Path, help='Already emitted QBE, x86 assembly, or x86 --emit object ELF; no compiler executes')
    parser.add_argument('--runtime-key', default='qbe-runtime')
    parser.add_argument('--runtime', type=Path, help='Explicit alternate object; policy remains unqualified')
    parser.add_argument('--runtime-argument-convention', choices=['bend-legacy-v1', 'bend-rts-v1'],
                        help='Explicit alternate object CLI only; does not qualify its semantic ABI')
    parser.add_argument('--runtime-abi', type=int, help='Explicit alternate object ABI; no ABI is inferred from its filename')
    parser.add_argument('--retain-ir', action='store_true')
    parser.add_argument('--expected-stdout', type=Path)
    parser.add_argument('--output-stage', help='Optional actual derived compiler generation, e.g. N1')
    parser.add_argument('--output-protocol', choices=['qbe-source-v1', 'native-c-source-v1', 'native-x86-source-v1'],
                        help='Derived compiler entry protocol; defaults to the selected target (explicit seed overrides supported)')
    result = build(parser.parse_args())
    print(json.dumps(result if result.get('complete') is False and 'wallSeconds' not in result else
        {k: result.get(k) for k in ('complete', 'wallSeconds',
            'objectDigest' if result.get('emissionFormat') == requests.X86_OBJECT_FORMAT else
            'assemblyDigest' if result.get('target') == 'x86' else 'irDigest', 'binary', 'error')}, indent=2))
    return 0 if result['complete'] or 'wallSeconds' not in result else 1


if __name__ == '__main__':
    sys.exit(main())
