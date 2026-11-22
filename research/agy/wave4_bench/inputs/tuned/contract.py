"""Read the frozen v1 contract and authenticate its sources before a run."""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def load():
    spec = json.loads((HERE/'suite.json').read_text())
    for relative, expected in spec['source_sha256'].items():
        if digest(ROOT/relative) != expected:
            raise ValueError(f'v1 source changed: {relative}')
    return spec
