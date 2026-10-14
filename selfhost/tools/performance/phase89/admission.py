"""Exact Phase89 image admission; offline preparation does not grant admission."""
import argparse
import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / 'phase88'))
from native_support import (ROOT, DEFAULT_CACHE, authenticate as authenticate_build,
                            pin, verify, require)

MANIFEST = HERE / 'native-admission.json'
# Root fills this only after reviewing successful real-image qualification.
ADMISSION_SHA = '9201ff03499900ed108b28b59ab24ecc79ccb7e9c64bb5765b105db7763a9a50'
SOURCE_SHA = '4584cf083d9eddad6f1290c9472c3aac2708099caa716a27f5b53fbcbaee1618'
ASSETS_SHA = '1894cef9f71d674507aa671cd5c24730ce221b23df7ca0f9675949336671ba2b'
ASSETS = HERE / 'native-b2/nine-effects.json'
LEGACY_IMAGE = ROOT / 'selfhost/build/phase88/compiler-native02'
EFFECT_NAMES = ['args.c', 'print.c', 'now.c', 'print_err.c', 'file_open.c',
                'file_read.c', 'file_size.c', 'file_write.c', 'file_close.c']


def read(path):
    return json.loads(Path(path).read_text())


def effect_assets():
    asset_pin = pin(ASSETS)
    require(asset_pin['sha256'] == ASSETS_SHA, 'Untrusted nine-effect manifest')
    assets = read(ASSETS)
    require([r['name'] for r in assets['admittedEffects']] == EFFECT_NAMES,
            'Wrong effect provider set')
    effects = [verify(r) for r in assets['admittedEffects']]
    require(all(Path(r['file']) == ROOT/'selfhost/src/runtime/native/effs'/name
                for name, r in zip(EFFECT_NAMES, effects)), 'Wrong effect paths')
    return asset_pin, effects


def successful(process):
    return (process.get('complete') and process.get('returncode') == 0
            and not process.get('stoppedFor'))


def same_output(actual, expected):
    return all(actual.get(k) == expected.get(k) for k in ('sha256', 'bytes'))


def validate_evidence(producer, cache, gates, broad, expected_ids):
    require(producer['cache'] is None and producer['source']['sha256'] == SOURCE_SHA,
            'Wrong native B1 source or producer mode')
    require(gates['kind'] == 'phase89-nine-effect-native-b1-gates'
            and gates['complete'] and gates['passed'] and not gates.get('checkOnly')
            and gates['liveQualified'] and gates['cacheQualifiedForThisExperiment'],
            'Incomplete live/cache qualification')
    require(gates['nativeB1'] == producer and gates['cacheOrigin'] == cache,
            'Gate producer/cache mismatch')
    names = {f'{mode}-{case}' for mode in ('live', 'cached')
             for case in ('small', 'map_closed', 'unicode', 'file-io')}
    require(len(gates['rows']) == 8 and {r['name'] for r in gates['rows']} == names,
            'Expected all eight live/cache gates')
    for row in gates['rows']:
        require(row['passed'] and row['exactC'] and row['inputBindingsUnchanged']
                and row['guardReturncode'] == 0 and successful(row['process'])
                and same_output(row['output'], row['oracle'])
                and row['mode'] == row['name'].split('-', 1)[0], 'Failed gate: ' + row['name'])
    require(broad['kind'] == 'phase89-native-broad-exact-c' and broad['complete']
            and broad['passed'] and broad['inputsUnchanged'] and broad['new'] == producer
            and broad['privateCache'] == cache, 'Incomplete/mismatched broad qualification')
    require(len(expected_ids) == len(set(expected_ids)) == len(broad['points']) == 45
            and {r['id'] for r in broad['points']} == set(expected_ids),
            'Wrong broad point set')
    covered = [name for row in broad['rows'] for name in row['ids']]
    require(len(covered) == 45 and set(covered) == set(expected_ids)
            and len(broad['rows']) == broad['distinctSources'], 'Incomplete grouped emissions')
    expected = {r['id']: r for r in broad['points']}
    for row in broad['rows']:
        require(row['passed'] and row['exact'] and row['job']['pass_']
                and successful(row['process']) and same_output(row['output'], row['expectedC']),
                'Failed broad group')
        for name in row['ids']:
            require(row['source'] == expected[name]['source']
                    and same_output(row['output'], expected[name]['expectedC']), 'Broad oracle mismatch')


def prepare(image, gates_path, broad_path, output):
    """Create a proposed manifest from completed real proofs; never change admission."""
    producer = authenticate_build(image, None)
    cache = authenticate_build(LEGACY_IMAGE, DEFAULT_CACHE)['cache']
    assets, effects = effect_assets()
    gates_pin, broad_pin = pin(gates_path), pin(broad_path)
    gates, broad = read(gates_path), read(broad_path)
    prior = read(ROOT/'selfhost/build/phase88/broad-qualified.json')
    require(prior['complete'] and prior['passed'] and prior['points'] == 45,
            'Incomplete reference catalog')
    expected_ids = sorted(row['id'] for row in prior['rows'])
    validate_evidence(producer, cache, gates, broad, expected_ids)
    require(gates['nineEffects'] == effects and gates['assets'] == assets,
            'Nine-effect qualification mismatch')
    # Qualification source/output files are needed at preparation time only.
    # Historical mutable production inputs are provenance, not launcher inputs.
    for row in gates['rows']:
        verify(row['source']); verify(row['output'])
    for row in broad['rows']:
        verify(row['source']); verify(row['output'])
    require(authenticate_build(image, None) == producer
            and authenticate_build(LEGACY_IMAGE, DEFAULT_CACHE)['cache'] == cache,
            'Producer/cache changed during preparation')
    manifest = dict(kind='phase89-qualified-native-b1', complete=True,
        canonicalRoot=str(ROOT), producer=producer, cache=cache, assets=assets,
        nineEffects=effects, gates=gates_pin, broad=broad_pin, expectedPointIds=expected_ids,
        scope='Exact upstream-built native B1, nine IO providers, eight live/cache gates and 45 exact-C points. No native B2 or full-language conformance claim.')
    with Path(output).open('x') as stream:
        json.dump(manifest, stream, indent=2); stream.write('\n')
    print(json.dumps(dict(proposedManifest=pin(output), admitted=False,
                         next='Review proof receipts, place at native-admission.json, then pin its digest in ADMISSION_SHA.')))


def authenticate(image, cache_receipt=None):
    require(ADMISSION_SHA is not None, 'Phase89 native image not admitted: qualification is pending')
    manifest_pin = pin(MANIFEST)
    require(manifest_pin['sha256'] == ADMISSION_SHA, 'Untrusted Phase89 admission manifest')
    manifest = read(MANIFEST)
    require(manifest['kind'] == 'phase89-qualified-native-b1' and manifest['complete']
            and manifest['canonicalRoot'] == str(ROOT), 'Wrong native admission/path')
    producer = authenticate_build(image, None)
    require(producer == manifest['producer'], 'Unqualified Phase89 image/source/C/build tuple')
    assets, effects = effect_assets()
    require(assets == manifest['assets'] and effects == manifest['nineEffects'], 'Changed native effects')
    gates_pin, broad_pin = verify(manifest['gates']), verify(manifest['broad'])
    gates, broad = read(gates_pin['file']), read(broad_pin['file'])
    cache = authenticate_build(LEGACY_IMAGE, DEFAULT_CACHE)['cache']
    require(cache == manifest['cache'] and gates['nineEffects'] == effects
            and gates['assets'] == assets, 'Changed cache/effect qualification')
    validate_evidence(producer, cache, gates, broad, manifest['expectedPointIds'])
    if cache_receipt is not None:
        require(Path(cache_receipt).resolve() == DEFAULT_CACHE.resolve(), 'Unqualified cache receipt path')
        require(verify(cache['receipt']) == pin(cache_receipt), 'Changed cache receipt')
    return dict(producer, cache=cache if cache_receipt is not None else None,
        nineEffects=effects, qualification=dict(manifest=manifest_pin, gates=gates_pin, broad=broad_pin, assets=assets),
        launcherMethods=[pin(path) for path in (HERE/'native.py', Path(__file__),
            HERE.parent/'phase88/native.py', HERE.parent/'phase88/native_support.py',
            HERE.parent/'phase86/guard.py')])


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    proposal = commands.add_parser('prepare', help='Offline proof validation; no targets or admission')
    for name in ('image', 'gates', 'broad', 'output'):
        proposal.add_argument(name, type=Path)
    check = commands.add_parser('check', help='Authenticate an admitted image without executing it')
    check.add_argument('image', type=Path)
    check.add_argument('--live', action='store_true')
    args = parser.parse_args()
    if args.command == 'prepare':
        prepare(args.image, args.gates, args.broad, args.output)
    else:
        print(json.dumps(authenticate(args.image, None if args.live else DEFAULT_CACHE), indent=2))
