"""Guarded release-N2/QBE image build with anonymous, bounded intermediate files."""

import argparse
from contextlib import ExitStack
import fcntl
import gzip
import hashlib
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
import assets
import common
import request

MIB = 1024 * 1024
P198 = ROOT / 'selfhost/build/phase198'
PREVIOUS = P198 / 'p199-integrated-native-image01/report.json'
MANIFEST = ROOT / 'selfhost/build/phase194/assets.json'


def raw_digest(stream, move_to=None, cap=None):
    h, size = hashlib.sha256(), 0
    for block in iter(lambda: stream.read(65536), b''):
        size += len(block)
        if cap is not None and size > cap:
            raise ValueError('Compiler product exceeds the declared maximum')
        h.update(block)
        if move_to is not None:
            move_to.write(block)
    return dict(bytes=size, sha256=h.hexdigest())


def data_identity(pin):
    return {key: pin[key] for key in ('bytes', 'sha256')}


def memory_file(stack, name):
    fd = os.memfd_create(name, os.MFD_CLOEXEC | os.MFD_ALLOW_SEALING)
    return stack.enter_context(os.fdopen(fd, 'w+b', buffering=0))


def freeze(stream, cap):
    size = os.fstat(stream.fileno()).st_size
    if not 0 < size <= cap:
        raise ValueError(f'Anonymous product size {size} exceeds its limit {cap}')
    fcntl.fcntl(stream.fileno(), fcntl.F_ADD_SEALS,
                fcntl.F_SEAL_WRITE | fcntl.F_SEAL_GROW | fcntl.F_SEAL_SHRINK | fcntl.F_SEAL_SEAL)
    stream.seek(0)
    result = raw_digest(stream, cap=cap)
    stream.seek(0)
    return result


def fdpath(stream):
    return '/proc/self/fd/' + str(stream.fileno())


def stage(out, name, command, descriptors, temporary, jobs):
    with (out / (name + '.stdout')).open('xb') as stdout, (out / (name + '.stderr')).open('xb') as stderr:
        result = subprocess.run(command, cwd=ROOT, env={**os.environ, 'TMPDIR': str(temporary)},
                                stdout=stdout, stderr=stderr, pass_fds=tuple(x.fileno() for x in descriptors))
    jobs.append(dict(label=name, command=command, exitCode=result.returncode,
                     stdout=common.pin(stdout.name), stderr=common.pin(stderr.name)))
    if result.returncode or (out / (name + '.stdout')).stat().st_size:
        raise ValueError(name + ' failed or emitted unexpected stdout')


def emit(out, asm, document, tools, plan, report):
    toolchain = assets.native_toolchain(document, 'qbe')
    command = [tools['qbe']['file'], '-t', toolchain['target'], '-o', fdpath(asm), '-']
    with ExitStack() as stack:
        qe = stack.enter_context((out/'qbe.stderr').open('xb'))
        qo = stack.enter_context((out/'qbe.stdout').open('xb'))
        ce = stack.enter_context((out/'compiler.stderr').open('xb'))
        qbe = subprocess.Popen(command, stdin=subprocess.PIPE, stdout=qo, stderr=qe,
                               start_new_session=True, pass_fds=(asm.fileno(),), cwd=ROOT)
        stack.callback(common.kill, qbe)
        comp = subprocess.Popen(plan['command'], stdout=subprocess.PIPE, stderr=ce, cwd=ROOT,
                                start_new_session=True)
        stack.callback(common.kill, comp)
        with comp.stdout, qbe.stdin:
            report['irDigest'] = raw_digest(comp.stdout, qbe.stdin, cap=512*MIB)
        report['compilerExitCode'] = comp.wait()
        report['qbeExitCode'] = qbe.wait()
    report.update(compilerStderr=common.pin(ce.name), qbeStderr=common.pin(qe.name),
                  qbeStdout=common.pin(qo.name), compilerCommand=plan['command'], qbeCommand=command)
    if report['compilerExitCode'] or report['qbeExitCode'] or any(report[k]['bytes'] for k in ('compilerStderr','qbeStderr','qbeStdout')):
        raise ValueError('Compiler/QBE failed or emitted diagnostics')


def run(args):
    common.clean_environment()
    assert os.sched_getaffinity(0) == {3}
    assert args.assets.resolve() == MANIFEST and args.seconds > 0
    out = common.fresh_output(args.out, ROOT)
    tmp = out / 'tool-tmp'
    tmp.mkdir()
    document = assets.load_assets(args.assets, ROOT)
    toolchain = assets.native_toolchain(document, 'qbe')
    tools = {name: assets.asset(document, name) for name in ('qbe', 'assembler', 'linker')}
    runtime = assets.asset(document, 'qbe-runtime')
    provider = assets.runtime_provider(document, 'qbe-runtime')
    assert (assets.runtime_abi(provider), assets.runtime_argument_convention(provider)) == (11102, 'bend-rts-v1')
    inputs = [common.pin(p) for p in (Path(__file__), common.__file__, request.__file__, assets.__file__, sys.executable)]
    inputs += [document['_manifest'], *tools.values(), runtime]
    prior, plan, archive = None, None, None
    if args.replay:
        inputs.append(common.pin(args.replay))
        prior = json.loads(args.replay.read_bytes())
        assert prior['complete'] and not prior['changedInputs'] and prior['toolchain'] == toolchain
        assert prior['runtime'] == runtime
        inputs.extend(prior[k] for k in ('object', 'binary'))
        if Path(prior['assembly']['file']).is_file():
            inputs.append(prior['assembly'])
        else:
            closure = ROOT/'selfhost/build-retention/phase200/authorized-assembly01'
            proof = closure/(args.replay.parent.name+'.verified.json')
            member = json.loads(proof.read_bytes())
            assert member['source'] == prior['assembly']['file']
            assert (member['originalBytes'], member['originalSha256']) == (prior['assembly']['bytes'], prior['assembly']['sha256'])
            archive = Path(member['archive'])
            inputs.extend([common.pin(proof), dict(file=str(archive),bytes=member['archiveBytes'],sha256=member['archiveSha256'])])
    else:
        assert args.host == 'native' and args.stage == 'N2' and args.target == 'qbe' and args.mode == 'cache'
        plan = request.plan(args)
        assert plan['imageMetadata']['protocol'] == 'qbe-source-v1' and plan['outputContract'] == 'stdout'
        inputs.extend(plan['inputs'])
        common.write_json(out/'request.json', plan)
    for item in inputs:
        common.verify(item)
    report = dict(kind='phase200-bounded-native-image', complete=False, inputs=inputs, runtime=runtime,
                  runtimeABI=11102, runtimeArgumentConvention='bend-rts-v1', jobs=[], request=plan,
                  toolchain=toolchain, transport='Anonymous sealed file descriptors for assembly and object; the IR uses a 64 KiB pipe relay.',
                  mode='predecessor-machine-replay' if prior else args.artifact)
    begin = time.monotonic()
    def deadline(signum, frame):
        raise TimeoutError('Whole image build deadline exceeded')
    signal.signal(signal.SIGALRM, deadline)
    signal.setitimer(signal.ITIMER_REAL, args.seconds)
    try:
        with ExitStack() as stack:
            assembly = memory_file(stack, 'phase200-assembly')
            obj = memory_file(stack, 'phase200-object')
            elf = memory_file(stack, 'phase200-linked-elf')
            if prior:
                with (gzip.open(archive,'rb') if archive else common.verify(prior['assembly']).open('rb')) as f:
                    assert raw_digest(f, assembly, 160*MIB) == data_identity(prior['assembly'])
            else:
                emit(out, assembly, document, tools, plan, report)
            report['assemblyDigest'] = freeze(assembly, 160*MIB)
            stage(out, 'assemble', [tools['assembler']['file'], *toolchain['assemblerFlags'],
                                   '-o', fdpath(obj), fdpath(assembly)], [assembly,obj], tmp, report['jobs'])
            report['objectDigest'] = freeze(obj, 64*MIB)
            # GNU ld records the argv spelling of the object in a local STT_FILE symbol.
            # Preserve the path that native.py uses while the object bytes live in RAM.
            object_path = common.verify(prior['object']) if prior else out/'program.o'
            if prior:
                assert report['objectDigest'] == data_identity(prior['object'])
            elif args.retain_object:
                with object_path.open('xb') as disk_object:
                    assert raw_digest(obj,disk_object,64*MIB) == report['objectDigest']
                report['object'] = common.pin(object_path)
            else:
                object_path.symlink_to(fdpath(obj))
            try:
                stage(out, 'link', [tools['linker']['file'], *toolchain['linkerFlags'], str(object_path), runtime['file'],
                                    *toolchain['libraries'], '-o', fdpath(elf)], [obj,elf], tmp, report['jobs'])
            finally:
                if not prior and not args.retain_object:
                    object_path.unlink()
            report['binaryDigest'] = freeze(elf, 64*MIB)
            if prior:
                for key in ('assembly', 'object', 'binary'):
                    assert report[key+'Digest'] == data_identity(prior[key]), key+' bytes differ'
                report['reference'] = common.pin(args.replay)
            elif args.artifact == 'gzip':
                packed = out/'program.gz'
                with packed.open('xb') as body, gzip.GzipFile(filename='', mode='wb', fileobj=body, mtime=0) as gz:
                    assert raw_digest(elf, gz, 64*MIB) == report['binaryDigest']
                with gzip.open(packed, 'rb') as restored:
                    assert raw_digest(restored, cap=64*MIB) == report['binaryDigest']
                report['compressedELF'] = common.pin(packed)
            else:
                image = out/'program'
                with image.open('xb') as f:
                    assert raw_digest(elf, f, 64*MIB) == report['binaryDigest']
                image.chmod(0o755)
                report['binary'] = common.pin(image)
                assert data_identity(report['binary']) == report['binaryDigest']
                report['imageBinding'] = dict(kind='bend-build-image-binding', version=1, complete=True,
                    image=report['binary'], sourceIdentity=plan['source'], host='native', stage='N1',
                    protocol='native-x86-source-v1', targets=['x86'], linkedRuntime=runtime,
                    runtimeArgumentConvention='bend-rts-v1', linkedRuntimeABI=11102, producer=plan['image'],
                    producerHost=plan['host'], producerStage=plan['stage'],
                    qualification='Built; semantic/self-host qualification is separate.')
        assert not any(tmp.iterdir()), 'Tool temporary directory contains retained files'
        report['changedInputs'] = common.changed_inputs(inputs)
        assert not report['changedInputs']
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
        if 'imageBinding' in report:
            report['imageBinding']['complete'] = False
        raise
    finally:
        signal.setitimer(signal.ITIMER_REAL, 0)
        report['wallSeconds'] = time.monotonic()-begin
        common.write_json(out/'report.json', report)
    print(json.dumps({k:report[k] for k in ('complete','mode','objectDigest','binaryDigest','wallSeconds')}))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    request.arguments(parser, source_required=False)
    parser.add_argument('--replay', type=Path, help='Original completed QBE N1 receipt to replay from its frozen assembly.')
    parser.add_argument('--artifact', choices=['raw','gzip'], default='raw')
    parser.add_argument('--retain-object',action='store_true', help='Retain the normal ELF object at its canonical path (requires ~44 MiB budget).')
    run(parser.parse_args())
