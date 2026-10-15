"""Private provenance for our C-backend images; never upstream acquisition."""
import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]
PERF = ROOT/'selfhost/tools/performance'
sys.path.insert(0, str(PERF/'phase88'))
from native_support import authenticate, native_args, pin, verify

SOURCE_SHA = 'd04ad79cf08c019b509cfbbd4be2b16ae9e4af189767715d12e0645b9eee8097'
ASSEMBLY_SHA = '9b4c0796b7504ebcb030ae9ffe5f4d0d37dbd6ac4637e4723acf895de196fea9'


def read(file):
    return json.loads(Path(file).read_text())


def emission_binding(file):
    """Verify actual producer receipts; never promote or execute anything."""
    inputs = {}
    def bind(record):
        actual = pin(record.get('file', record.get('path')))
        assert actual['sha256'] == record['sha256'], actual['file']
        if 'bytes' in record:
            assert actual['bytes'] == record['bytes']
        prior = inputs.setdefault(actual['file'], actual)
        assert prior == actual
        return actual
    emission_pin = bind(pin(file))
    report = read(file)
    assert report['complete']
    kind = report['kind']
    if kind == 'phase90-native-b1-self-emission':
        producer = report['producer']
        assert producer['stage'] == 'upstream-built native B1'
        actual = authenticate(producer['authentication']['image']['file'], None)
        assert actual == producer['authentication']
        assert actual['source']['sha256'] == SOURCE_SHA
        checked = read(bind(actual['checked'])['file'])
        assert checked['kind'] == 'phase90-checked-upstream-native-source-derivative'
        assert checked['holes'] == 0 and checked['inputsUnchanged']
        for record in checked['inputs']:
            bind(record)
        qualification = bind(report['qualification'])
        gates = read(qualification['file'])
        assert gates['kind'] == 'phase90-combined-native-b1-gates'
        assert gates['complete'] and gates['passed'] and gates['liveQualified'] and gates['cacheQualifiedForThisExperiment']
        assert gates['executionPerformed'] and not gates['checkOnly'] and len(gates['rows']) == 8
        assert gates['nativeB1'] == actual
        assert all(row['passed'] and row['exactC'] and row['inputBindingsUnchanged'] for row in gates['rows'])
        for record in gates['inputs']:
            bind(record)
        source, c = bind(report['source']), bind(report['c'])
        assert bind(report['derivation'])['sha256'] == ASSEMBLY_SHA
        process_file = Path(report['guard'])/'process.json'
        process = read(bind(pin(process_file))['file'])
        assert process['complete'] and process['returncode'] == 0 and not process.get('stoppedFor')
        for record in read(bind(pin(Path(report['guard'])/'inputs.json'))['file']):
            bind(record)
        assert actual['image']['file'] in process['command'] and source['file'] in process['command']
        provenance = 'native-B1-self-emitted-C'
    elif kind == 'phase90-js-b1-combined-source-emission':
        assert report['inputsUnchanged'] and report['stage'] == 'complete'
        assert report['observation']['status'] == 'ok' and report['observation']['checked']
        assert len(report['policy']) == 4 and all(value == 0 for value in report['policy'].values())
        for record in report['inputs']:
            bind(record)
        method = bind(pin(PERF/'phase90/bootstrap/emit-self-v7.mjs'))
        assert method['sha256'] == '712e639ef3adb0ef265749d6ab32d8121bb89276a52ace5ee1da5678c7d3df0d'
        assert method in report['inputs']
        producer = report['producer']
        assert producer['stage'] == 'checked equality-derived JS-hosted Bend B1'
        attempt_pin, validation_pin = bind(producer['attempt']), bind(producer['validation'])
        attempt, validation = read(attempt_pin['file']), read(validation_pin['file'])
        assert attempt['checked'] and attempt['artifactKind'] == 'derived-b1'
        assert validation['complete'] and validation['pass'] and validation['strictExact']
        for field, key in [('api', 'api'), ('checkedApi', 'checkedApi'),
                           ('bootstrap', 'bootstrapReport'), ('derivation', 'derivationReport')]:
            assert bind(producer[field]) == bind(attempt[key])
        assert bind(validation['api']) == bind(producer['api'])
        bootstrap, derivation = read(producer['bootstrap']['file']), read(producer['derivation']['file'])
        assert bootstrap['stage'] == 'upstream-bootstrap' and bootstrap['revision'] == '059266225b77c8ca256ac6b25ee5c21449bab151'
        assert bootstrap['apiSha256'] == producer['checkedApi']['sha256']
        assert derivation['kind'] == 'bend-derived-b1-equality' and derivation['complete'] and not derivation['newBootstrap']
        assert bind(derivation['original']['api']) == bind(producer['checkedApi'])
        assert bind(derivation['original']['bootstrapReport']) == bind(producer['bootstrap'])
        assert bind(derivation['output']) == bind(producer['api'])
        source, c = bind(report['subject']), bind(report['output'])
        assert report['sourceDerivation']['inverseRecoversAncestor'] and report['sourceDerivation']['exactOutsideReplacements']
        assembly_pin = bind(report['sourceDerivation']['assembly'])
        assert assembly_pin['sha256'] == ASSEMBLY_SHA
        assembly = read(assembly_pin['file'])
        assert assembly['complete'] and assembly['exactOutsideDefinitions'] and len(assembly['replacements']) == 14
        for record in assembly['inputs']:
            bind(record)
        assert bind(assembly['output']) == source
        original = Path(assembly['inputs'][0]['file']).read_text()
        forward = original
        for change in assembly['replacements']:
            assert forward.count(change['old']) == 1
            forward = forward.replace(change['old'], change['new'], 1)
        assert forward == Path(source['file']).read_text()
        for change in reversed(assembly['replacements']):
            assert forward.count(change['new']) == 1
            forward = forward.replace(change['new'], change['old'], 1)
        assert forward == original
        # The root guard uses the existing sibling NAME-guard convention.
        directory = Path(file).resolve().parent
        guard_directory = directory.with_name(directory.name + '-guard')
        guard = read(bind(pin(guard_directory/'process.json'))['file'])
        guard_inputs = [bind(record) for record in read(bind(pin(guard_directory/'inputs.json'))['file'])]
        assert guard['complete'] and guard['returncode'] == 0 and not guard.get('stoppedFor')
        expected_tail = [Path(method['file']), Path(attempt_pin['file']).parent, directory]
        assert [(ROOT/part).resolve() for part in guard['command'][-3:]] == expected_tail
        assert bind(producer['node']) in guard_inputs and method in guard_inputs
        assert producer['node']['file'] in guard['command']
        provenance = 'JS-B1-cross-host-emitted-C'
    else:
        assert kind == 'phase90-qualified-js-b2-combined-source-emission'
        assert report['inputsUnchanged'] and report['verification']['inputsUnchanged'] and report['verification']['copiesUnchanged']
        assert report['observation']['status'] == 'ok' and report['observation']['checked']
        assert len(report['policy']) == 4 and all(value == 0 for value in report['policy'].values())
        for record in report['inputs']:
            bind(record)
        producer = report['producer']
        assert producer['stage'] == 'self-emitted driver-qualified JS-hosted Bend B2'
        pins = read(bind(producer['imagePins'])['file'])
        assert pins['kind'] == 'phase56-direct-image-pins'
        for key in ['attempt', 'emission', 'comparison']:
            assert bind(producer[key])['sha256'] == bind(pins[key])['sha256']
        assert bind(producer['api'])['sha256'] == bind(pins['b2'])['sha256']
        assert bind(producer['generator'])['sha256'] == bind(pins['b1'])['sha256']
        assert read(pins['emission']['file'])['pass'] and read(pins['comparison']['file'])['pass']
        assert report['sourceDerivation']['inverseRecoversAncestor']
        assert bind(report['sourceDerivation']['assembly'])['sha256'] == ASSEMBLY_SHA
        source, c = bind(report['subject']), bind(report['output'])
        provenance = 'JS-B2-cross-host-emitted-C'
    assert source['sha256'] == SOURCE_SHA and 0 < c['bytes'] <= 64*1024*1024
    return dict(emission=emission_pin, producer=producer, provenance=provenance,
                source=source, c=c, inputs=list(inputs.values()))


def bind_build(emission, guard_directory, binary):
    binding = emission_binding(emission)
    guard_pin, inputs_pin = pin(Path(guard_directory)/'process.json'), pin(Path(guard_directory)/'inputs.json')
    guard, raw_inputs = read(guard_pin['file']), read(inputs_pin['file'])
    assert guard['complete'] and guard['returncode'] == 0 and not guard.get('stoppedFor')
    image = pin(binary)
    inputs = [verify(record) for record in raw_inputs]
    assert image['file'] in guard['command'] and binding['c']['file'] in guard['command']
    assert binding['c'] in inputs
    emission_inputs = binding.pop('inputs')
    return dict(kind='phase90-own-backend-native-image', complete=True, method=pin(__file__),
                **binding, binary=image, guard=guard_pin, buildInputs=inputs_pin, inputs=inputs,
                emissionInputs=emission_inputs, command=guard['command'],
                argvSentinel='phase90-native', nativeB2Qualified=False, cacheAdmitted=False,
                scope='Recorded Bend C emission plus actual guarded Clang build. Execution qualification and public/cache admission are separate.')


def authenticate_own(image, cache_receipt=None):
    assert cache_receipt is None, 'This authenticator grants no cache admission'
    image = pin(image)
    receipt = pin(image['file']+'.own-build.json')
    record = read(receipt['file'])
    assert record['kind'] == 'phase90-own-backend-native-image' and record['complete']
    assert verify(record['binary']) == image
    current = bind_build(record['emission']['file'], Path(record['guard']['file']).parent, image['file'])
    assert current == record, 'Own-backend image provenance changed'
    # Reuse the independently authenticated transport, never its producer claim.
    origin = authenticate(ROOT/'selfhost/build/phase88/compiler-native02', None)
    assets = {key: origin[key] for key in ['base', 'runtime', 'runtimeParts', 'template', 'effectsDir', 'effects']}
    return dict(image=image, source=record['source'], c=record['c'], build=receipt,
                emission=record['emission'], producer=record['producer'], provenance=record['provenance'],
                bindingInputs=record['emissionInputs'], guard=record['guard'], buildInputs=record['buildInputs'],
                assetOrigin=dict(image=origin['image'], build=origin['build'], checked=origin['checked']),
                **assets, cache=None, argvSentinel=record['argvSentinel'])


def own_args(auth, source, output_prefix, calls=1):
    command = native_args(auth, source, output_prefix, calls)
    index = command.index('--')+1
    command.insert(index, auth['argvSentinel'])
    return command
