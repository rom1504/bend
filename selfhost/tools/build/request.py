#!/usr/bin/env python3
"""Capture one explicitly bound compiler request. Run inside the existing disk guard."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import sys
import time

sys.dont_write_bytecode = True
import assets
from common import (ROOT, changed_inputs, clean_environment, fresh_output, pin,
                    require, run, same_bytes, timeout, verify, workspace, write_json)


def runtime_parts(template, raw):
    """Authenticate existing Bend-produced insertion boundaries; do not rediscover them."""
    require(template['bytes'] <= 16777216 and raw['bytes'] <= 16777216, 'Runtime transport exceeds bound')
    artifact = json.loads(verify(template).read_text())
    require(artifact.get('version') == 1 and artifact.get('runtimeSha256') == raw['sha256'],
            'Canonical runtime template/raw identity mismatch')
    parts = artifact.get('parts')
    require(isinstance(parts, list) and len(parts) == 5 and all(isinstance(p, str) for p in parts),
            'Exactly five Bend-produced runtime parts required')
    encoded = [part.encode('utf8') for part in parts]
    require(b''.join(encoded) == verify(raw).read_bytes(), 'Prepared runtime concatenation differs from raw bytes')
    return encoded


def prepare_runtime(preparation):
    parts = runtime_parts(preparation['template'], preparation['raw'])
    prefix = Path(preparation['prefix'])
    with prefix.open('xb') as stream:
        stream.write(verify(preparation['raw']).read_bytes())
    produced = [pin(prefix)]
    for expected, part in zip(preparation['parts'], parts):
        require(len(part) == expected['bytes'] and hashlib.sha256(part).hexdigest() == expected['sha256'],
                'Runtime part boundaries changed after preflight')
        with Path(expected['file']).open('xb') as stream:
            stream.write(part)
        verify(expected)
        produced.append(expected)
    return produced


def proof_verdict(data):
    """Exact driver report grammar shared by public and prepared native entries."""
    require(len(data) <= 16777216, 'Native C diagnostic stream exceeds bound')
    verdict = data.decode('utf8')
    if verdict == 'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n\n':
        proof = dict(status='all-check', unsafeOrForeignCount=0, names=[])
    else:
        lines = verdict.split('\n')
        require(len(lines) >= 5 and lines[0] == 'SOME PROOFS FAIL' and lines[-2:] == ['', ''],
                'Unknown native C verdict/extra diagnostics')
        count = re.fullmatch(r'Error: ([1-9][0-9]{0,6}) (def relies|defs rely) on unsafe or foreign code:', lines[1])
        require(count is not None, 'Malformed unsafe/foreign verdict')
        size = int(count[1])
        require((count[2] == 'def relies') == (size == 1), 'Verdict count/plural mismatch')
        names = lines[2:-2]
        require(len(names) == size and all(re.fullmatch(r'- [^\x00-\x1f\x7f]+', name) for name in names),
                'Verdict definition count/names differ')
        proof = dict(status='unsafe-or-foreign', unsafeOrForeignCount=size, names=[name[2:] for name in names])
    return proof


def c_telemetry(data, product):
    """Recognize the exact successful p86 protocol, preserving unsafe/foreign verdicts."""
    require(len(data) <= 16777216, 'Native C diagnostic stream exceeds bound')
    text = data.decode('utf8')
    number = r'(0|[1-9][0-9]{0,19})'
    match = re.match(r'\Abase_prepare_ms=' + number + r'\nruntime_prepare_ms=' + number
                     + r'\nrequest=1 request_ms=' + number + r' consumed_chars=' + number + r'\n', text)
    require(match is not None, 'Malformed or reordered native C timing protocol')
    verdict = text[match.end():]
    proof = proof_verdict(verdict.encode('utf8'))
    # p86_consumed counts the source and verdict, before IO.print_err's extra LF.
    consumed = len(product.decode('utf8')) + len(verdict[:-1])
    require(int(match[4]) == consumed, 'Native C consumed-character count differs from complete product/verdict')
    return dict(basePrepareMs=int(match[1]), runtimePrepareMs=int(match[2]),
                requestMs=int(match[3]), consumedChars=int(match[4]), proofVerdict=proof,
                mathematicalValidityClaim=False)


def public_package(image, metadata, mode):
    """Bind the public image's sibling assets; never load its historical build inputs."""
    expected = metadata.get('packageAssets')
    effects = ['args','print','print_err','now','file_open','file_read','file_size','file_write','file_close']
    names = {'base.bend','base.p88', *('runtime.c.part'+str(i) for i in range(5)),
             *('effs/'+name+'.c' for name in effects)}
    require(isinstance(expected, dict) and set(expected) == names, 'Exact public CLI asset inventory required')
    require(mode in ('cache','live') and Path(metadata.get('baseIdentity','')).is_absolute()
            and re.fullmatch(r'p88-private-base-text-1:[0-9a-f]{64}', metadata.get('cacheStamp','')),
            'Explicit public CLI Base identity/cache contract required')
    files = {}
    for name in sorted(names):
        actual = pin(Path(image['file']).parent/'assets'/name)
        require(0 <= actual['bytes'] <= 16777216 and all(actual[k] == expected[name][k] for k in ('bytes','sha256')),
                'Public CLI sibling asset differs: ' + name)
        files[name] = actual
    require(sum(row['bytes'] for row in files.values()) <= 33554432, 'Public CLI asset set exceeds bound')
    runtime = b''.join(verify(files['runtime.c.part'+str(i)]).read_bytes() for i in range(5))
    identity = dict(bytes=len(runtime), sha256=hashlib.sha256(runtime).hexdigest())
    require(all(identity[k] == metadata.get('targetRuntime',{}).get(k) for k in identity),
            'Public CLI runtime parts differ from their declared target runtime')
    return dict(base=files['base.bend'], carrier=files['base.p88'] if mode == 'cache' else None,
                stamp=metadata['cacheStamp'] if mode == 'cache' else '', inputs=list(files.values()),
                baseIdentity=metadata['baseIdentity'], runtimeIdentity=identity,
                providers=dict(runtimeParts=[files['runtime.c.part'+str(i)] for i in range(5)],
                               effects=[files['effs/'+name+'.c'] for name in effects]))


def arguments(parser, *, source_required=True):
    parser.add_argument('--workspace', type=Path)
    parser.add_argument('--assets', type=Path, required=True)
    choice = parser.add_mutually_exclusive_group(required=source_required)
    choice.add_argument('--image-key')
    choice.add_argument('--image', type=Path)
    parser.add_argument('--image-receipt', type=Path)
    parser.add_argument('--source', type=Path, required=source_required)
    parser.add_argument('--host', choices=['native', 'js'], required=source_required)
    parser.add_argument('--target', choices=['js', 'c', 'qbe', 'x86'], default='qbe')
    parser.add_argument('--stage', required=source_required,
                        help='Actual executing image generation, e.g. B1, B2, N1, N2')
    parser.add_argument('--mode', choices=['cache', 'live'], default='cache')
    parser.add_argument('--base-key', default='base')
    parser.add_argument('--carrier-key', default='prepared-base')
    parser.add_argument('--engine-key', default='bun')
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--seconds', type=float, default=600)
    parser.add_argument('--expected', '--expected-qbe', '--expected-assembly', dest='expected', type=Path)
    parser.add_argument('--plan', action='store_true', help='Print the authenticated plan; execute nothing')


def image_binding(args, document):
    if args.image_key:
        image, metadata = assets.image(document, args.image_key, args.host, args.stage, args.target)
        return image, metadata, [image]
    require(args.image and args.image_receipt, '--image requires its explicit --image-receipt')
    image = pin(args.image / 'program' if args.image.is_dir() else args.image)
    receipt_pin = pin(args.image_receipt)
    receipt = json.loads(verify(receipt_pin).read_text())
    metadata = receipt.get('imageBinding') if 'imageBinding' in receipt else receipt
    require(receipt.get('complete') is True and isinstance(metadata, dict)
            and metadata.get('kind') == 'bend-build-image-binding'
            and metadata.get('complete') is True, 'Complete maintained image binding required')
    bound = metadata['image']
    require(all(image[k] == bound[k] for k in ('bytes', 'sha256')), 'Image differs from its binding')
    require(metadata.get('host') == args.host and metadata.get('stage') == args.stage,
            'Host/stage differ from actual recorded image')
    require(args.target in metadata.get('targets', []), 'Image does not advertise requested target')
    return image, metadata, [image, receipt_pin]


def plan(args):
    root = workspace(args.workspace)
    timeout(args.seconds)
    clean_environment()
    document = assets.load_assets(args.assets, root)
    image, metadata, image_inputs = image_binding(args, document)
    source = pin(args.source)
    require(0 < source['bytes'] <= 16777216, 'Nonempty source must fit the bounded native reader')
    protocol = metadata.get('protocol')
    public = public_package(image, metadata, args.mode) if protocol == 'native-public-cli-v1' else None
    if public:
        require(args.host == 'native' and args.target == 'c', 'Public native CLI emits C only')
        require(args.base_key == 'base' and args.carrier_key == 'prepared-base', 'Public CLI owns its Base/cache; key overrides are unsupported')
        base, carrier, stamp, preparation_inputs = (public[k] for k in ('base','carrier','stamp','inputs'))
    else:
        base, carrier, stamp, preparation_inputs = assets.prepared_base(document, args.mode, args.base_key, args.carrier_key)
    require(args.mode in metadata.get('preparationModes', ['cache', 'live']),
            'Preparation mode is not supported by this image contract')
    inputs = [document['_manifest'], pin(__file__), pin(assets.__file__),
              pin(Path(__file__).with_name('common.py')), pin(sys.executable), source,
              *image_inputs, *preparation_inputs]
    providers = public['providers'] if public else {}
    for name, keys in ({} if public else document.get('providers', {}).get(args.target, {})).items():
        values = [assets.asset(document, key) for key in keys] if isinstance(keys, list) else assets.asset(document, keys)
        providers[name] = values
        inputs.extend(values if isinstance(values, list) else [values])
    result = dict(kind='bend-build-request-plan', version=1, host=args.host,
                  target=args.target, stage=args.stage, mode=args.mode, image=image,
                  imageMetadata=metadata, source=source, base=base, carrier=carrier,
                  stamp=stamp, providers=providers, workspace=str(root), inputs=inputs,
                  imageRuntime=metadata.get('linkedRuntime'),
                  runtimeRole='Image linked-runtime identity is distinct from target provider/build runtime.',
                  expected=pin(args.expected) if args.expected else None)
    if result['expected']:
        inputs.append(result['expected'])
    if public:
        result['publicPackage'] = public
    out = args.out.resolve()
    if args.host == 'native':
        require(os.access(image['file'], os.X_OK), 'Native image must be executable')
        convention = assets.runtime_argument_convention(metadata)
        result['runtimeArgumentConvention'] = convention
        require(convention != 'bend-rts-v1' or 'BENDRTS' not in os.environ,
                'Explicit RTS requests require ambient BENDRTS to be unset')
        command = [image['file'], *assets.runtime_arguments(metadata, application=True)]
        if protocol == 'native-public-cli-v1':
            result['emittedFile'] = str(out / 'program.c')
            # This protocol's startup wrapper owns runtime flags and argv[0].
            command = [image['file'], source['file'], '-o', result['emittedFile']]
            if args.mode == 'live':
                command.append('--live')
            result['outputContract'] = 'file'
        elif protocol == 'qbe-source-v1':
            require(args.target == 'qbe', 'Native qbe-source-v1 only emits QBE')
            command += ['phase111', source['file'], base['file'], args.mode,
                        carrier['file'] if carrier else '', stamp]
            result['outputContract'] = 'stdout'
        elif protocol == 'native-x86-source-v1':
            require(args.target == 'x86', 'Native x86 protocol only emits assembly')
            command += ['x86', source['file'], base['file'], args.mode,
                        carrier['file'] if carrier else '', stamp]
            result['outputContract'] = 'stdout'
        elif protocol == 'native-c-source-v1':
            require(args.target == 'c', 'native-c-source-v1 only emits C')
            require('runtime' in providers and 'effects' in providers, 'C providers must be declared')
            effects = providers['effects']
            require(effects and len({str(Path(p['file']).parent) for p in effects}) == 1,
                    'C foreign effects must occupy one explicitly pinned directory')
            require('runtimeTemplate' in providers, 'Native C requires the authenticated Bend-produced runtime template')
            parts = runtime_parts(providers['runtimeTemplate'], providers['runtime'])
            prefix = str(out / 'runtime.c')
            result['runtimePreparation'] = dict(template=providers['runtimeTemplate'], raw=providers['runtime'],
                prefix=prefix, concatenationExact=True, parts=[dict(file=prefix+'.part'+str(i),
                    bytes=len(part), sha256=hashlib.sha256(part).hexdigest()) for i,part in enumerate(parts)],
                origin='Existing Bend-produced canonical template boundaries; host only authenticates/transports bytes.')
            sentinel = metadata.get('argvSentinel')
            if sentinel:
                command.append(sentinel)
            command += [source['file'], base['file'], prefix,
                        str(Path(effects[0]['file']).parent), str(out / 'program'), '1']
            if carrier:
                command += [carrier['file'], stamp]
            result['outputContract'] = 'file'
            result['emittedFile'] = str(out / 'program.1.c')
        else:
            raise ValueError('Unsupported explicit native protocol: ' + str(protocol))
    else:
        require(args.target != 'x86', 'x86 assembly requires an explicit native emitter image')
        require(protocol in ('qbe-api-v1', 'typed-api-v1', 'hosted-api-v1'), 'Unsupported checked JS API protocol')
        require(metadata.get('checked') is True, 'Checked hosted API binding required')
        result['engine'] = assets.asset(document, args.engine_key)
        worker = Path(__file__).with_name('hosted.mjs')
        inputs.extend([result['engine'], pin(worker)])
        command = [result['engine']['file'], str(worker), '--request', str(out / 'request.json'),
                   '--report', str(out / 'hosted.json')]
        result['outputContract'] = 'stdout'
    result['command'] = command
    for row in inputs:
        verify(row)
    return result


def execute(args, request=None):
    request = request or plan(args)
    root = Path(request['workspace'])
    out = fresh_output(args.out, root)
    write_json(out / 'request.json', request)
    suffix = {'qbe': 'ssa', 'x86': 's', 'c': 'c', 'js': 'mjs'}[request['target']]
    product = Path(request.get('emittedFile', out / ('program.' + suffix)))
    report = dict(kind='bend-build-request', version=1, complete=False,
                  request=request, inputs=request['inputs'], host=request['host'],
                  target=request['target'], stage=request['stage'], mode=request['mode'],
                  image=request['image'], source=request['source'], base=request['base'],
                  preparedBase=request['carrier'], imageRuntime=request['imageRuntime'],
                  byteContract='Complete emitted bytes; native stdout includes every IO.print LF, without normalization.',
                  timingScope='Whole child request including reads/output. Preflight and post-return identity checks excluded. Outer guard owns CPU/RSS/disk.')
    start = time.monotonic()
    prepared_inputs = []
    write_json(out / 'report.json', report)
    try:
        if request.get('runtimePreparation'):
            prepared_inputs = prepare_runtime(request['runtimePreparation'])
            report['runtimePreparation'] = dict(request['runtimePreparation'], produced=prepared_inputs)
        stdout = product if request['outputContract'] == 'stdout' else out / 'compiler.stdout'
        child = run(request['command'], cwd=root, stdout=stdout, stderr=out / 'emit.stderr', seconds=args.seconds)
        report['process'] = child
        report['nativeSeconds' if request['host'] == 'native' else 'hostedSeconds'] = child['seconds']
        require(child['complete'], 'Compiler request failed or timed out')
        report['product'] = pin(product)
        require(report['product']['bytes'] > 0, 'Empty emitted product')
        if request['host'] == 'native' and request['imageMetadata']['protocol'] == 'native-c-source-v1':
            require(child['stdout']['bytes'] == 0, 'Unexpected native C stdout')
            report['telemetry'] = c_telemetry(verify(child['stderr']).read_bytes(), product.read_bytes())
        elif request['host'] == 'native' and request['imageMetadata']['protocol'] == 'native-public-cli-v1':
            require(child['stdout']['bytes'] == 0, 'Unexpected public CLI stdout')
            report['publicVerdict'] = dict(proofVerdict=proof_verdict(verify(child['stderr']).read_bytes()),
                                          mathematicalValidityClaim=False)
        else:
            require(child['stderr']['bytes'] == 0, 'Unexpected compiler stderr')
        if request['host'] == 'js':
            hosted = json.loads((out / 'hosted.json').read_text())
            require(hosted.get('complete') is True, 'Hosted adapter receipt incomplete')
            report['hostedReport'] = pin(out / 'hosted.json')
        if request['expected']:
            report['byteExact'] = same_bytes(product, request['expected']['file'])
            require(report['byteExact'], 'Complete emitted bytes differ from independent reference')
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        report['changedInputs'] = changed_inputs(request['inputs'] + prepared_inputs)
        if report['changedInputs']:
            report['complete'] = False
        if product.is_file():
            report['product'] = pin(product)
        report['totalSeconds'] = time.monotonic() - start
        write_json(out / 'report.json', report)
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    arguments(parser)
    args = parser.parse_args()
    request = plan(args)
    if args.plan:
        print(json.dumps(request, indent=2))
        return 0
    result = execute(args, request)
    print(json.dumps({k: result.get(k) for k in ('complete', 'product', 'nativeSeconds', 'hostedSeconds', 'error')}))
    return 0 if result['complete'] else 1


if __name__ == '__main__':
    sys.exit(main())
