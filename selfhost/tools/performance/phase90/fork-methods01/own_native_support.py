"""Private provenance for our C-backend images; never upstream acquisition."""
import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]
PERF = ROOT/'selfhost/tools/performance'
sys.path.insert(0, str(PERF/'phase88'))
from native_support import authenticate, native_args, pin, verify

SOURCE_SHA = 'd8a94ce9f16e7576d2f4269c858d008e3da2f40f734cdf0983a3a9835f330791'
ASSEMBLY_SHA = '21a6140df89ff3f0757e78652ad234d37fd220fc774ff705fa289b2d2f3179ff'


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
