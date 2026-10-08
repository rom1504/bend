#!/usr/bin/env python3
"""Bind existing genuine B2 emission receipts; no image generation or execution."""
import argparse
import hashlib
import json
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('image_pins', type=Path)
parser.add_argument('output', type=Path)
args = parser.parse_args()
assert not args.output.exists(), 'Keep prior control inputs immutable'
here = Path(__file__).resolve().parent


def read(file):
    return json.loads(Path(file).read_text())


def pin(file):
    file = Path(file).resolve()
    data = file.read_bytes()
    return {'file': str(file), 'sha256': hashlib.sha256(data).hexdigest(), 'bytes': len(data)}


origin = read(args.image_pins)
assert origin['kind'] == 'phase56-direct-image-pins'
for key in ['producer', 'plan', 'attempt', 'emission', 'comparison', 'source', 'b1',
            'b2', 'runtime', 'rootsReference', 'admission']:
    assert pin(origin[key]['file'])['sha256'] == origin[key]['sha256']
attempt = read(origin['attempt']['file'])
emission = read(origin['emission']['file'])
comparison = read(origin['comparison']['file'])
assert attempt['checked'] and emission['complete'] and emission['pass']
assert comparison['complete'] and comparison['pass'] and comparison['observations'] == 8
assert len(origin['roots']) == len(set(origin['roots'])) == 99
assert origin['b1']['sha256'] == attempt['api']['sha256']
assert origin['b2']['sha256'] == emission['module']['sha256']
previous = read(here / 'annotation-controls-checked03-input-v4.json')
config = {
    'kind': 'phase66-base-annotation-genuine-b2-controls-input',
    'generation': 'genuine-B2',
    'imagePins': pin(args.image_pins),
    'image': {'api': pin(origin['b2']['file']),
              'driver': pin(Path(attempt['snapshot']['root']) / 'tools/typed-driver.mjs'),
              **{key: pin(attempt[key]['file']) for key in ['runtime', 'base', 'node']}},
    'provenance': [pin(__file__), pin(here / 'annotation-controls-b2-v1-derivation.json')],
    'sources': previous['sources'],
}
args.output.parent.mkdir(parents=True, exist_ok=True)
with args.output.open('x') as file:
    file.write(json.dumps(config, indent=2) + '\n')
print(json.dumps(pin(args.output)))
