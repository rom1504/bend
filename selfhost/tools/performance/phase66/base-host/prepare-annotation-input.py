#!/usr/bin/env python3
"""Pin an existing checked/derived image for root-run H2 controls; execute nothing."""
import argparse
import hashlib
import json
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('attempt', type=Path)
parser.add_argument('output', type=Path)
parser.add_argument('--derivation', type=Path)
args = parser.parse_args()
assert not args.output.exists(), 'Keep prior control inputs immutable'
here = Path(__file__).resolve().parent
root = here.parents[4]


def read(file):
    return json.loads(Path(file).read_text())


def pin(file):
    file = Path(file).resolve()
    data = file.read_bytes()
    return {'file': str(file), 'sha256': hashlib.sha256(data).hexdigest(), 'bytes': len(data)}


attempt_file = args.attempt / 'attempt.json' if args.attempt.is_dir() else args.attempt
attempt = read(attempt_file)
assert attempt['kind'] == 'bend-development-attempt' and attempt['checked']
assert attempt['artifactKind'] in ['checked-b1', 'derived-b1']
bootstrap = read(attempt['bootstrapReport']['file'])
assert bootstrap['revision'] == '059266225b77c8ca256ac6b25ee5c21449bab151'
driver = pin(Path(attempt['snapshot']['root']) / 'tools/typed-driver.mjs')
transforms = []
next_hash = driver['sha256']
for name in ['bootstrap-default-v1', 'annotations-qualified-v1']:
    file = here / (name + '.json')
    item = read(file)
    if next_hash == item['beforeSha256']:
        transforms.append(pin(file))
        next_hash = item['afterSha256']
candidate = pin(read(here / 'annotations-qualified-v1.json')['candidate'])
assert next_hash == candidate['sha256'], 'Unreviewed host source; prepare a new transform'
old = read(root / 'selfhost/tools/performance/phase65/base-products/annotation-controls-state08-input-v2.json')
config = {
    'kind': 'phase66-base-annotation-owned-controls-input',
    'generation': 'checked-B1',
    'checkedAttempt': pin(attempt_file),
    'hostTransforms': transforms,
    'driverCandidate': candidate,
    'image': {'api': pin(attempt['checkedApi']['file']), 'driver': driver,
              **{key: pin(attempt[key]['file']) for key in ['runtime', 'base', 'node']}},
    'provenance': [pin(__file__), pin(here / 'annotation-controls-v4-derivation.json')],
    'sources': [{key: value for key, value in row.items() if key != 'expectedOutput'} for row in old['sources']],
}
if attempt['artifactKind'] == 'derived-b1':
    selected_receipt = Path(attempt['derivationReport']['file'])
    if args.derivation:
        assert args.derivation.resolve() == selected_receipt.resolve()
    args.derivation = selected_receipt
if args.derivation:
    derivation = read(args.derivation)
    assert derivation['complete'] and not derivation['newBootstrap']
    assert derivation['transform']['version'] == 7
    assert derivation['original']['api']['sha256'] == config['image']['api']['sha256']
    config.update(generation='equality-derived-B1-profile7', derivation=pin(args.derivation),
                  equalityVerifier=pin(derivation['toolSnapshot']['file']))
    config['image']['api'] = pin(derivation['output']['file'])
args.output.parent.mkdir(parents=True, exist_ok=True)
with args.output.open('x') as file:
    file.write(json.dumps(config, indent=2) + '\n')
print(json.dumps(pin(args.output)))
