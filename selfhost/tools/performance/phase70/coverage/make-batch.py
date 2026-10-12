#!/usr/bin/env python3
"""Reuse Phase46's four-line wrapper exactly with a new source directory/catalog."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
parent = ROOT / 'selfhost/tools/performance/phase46/make-batch.py'
spec = importlib.util.spec_from_file_location('phase70_batch_parent', parent)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--out', type=Path, default=HERE)
args = parser.parse_args()
args.out.mkdir(parents=True, exist_ok=True)
module.HERE = args.out.resolve()
cases = json.loads((HERE / 'cases.json').read_text())
outputs = [(args.out / (c['name'] + '-batch.bend'), module.source(c)) for c in cases]
assert all(not path.exists() for path, _ in outputs), 'Never replace existing wrappers'
for path, source in outputs:
    with path.open('x') as out:
        out.write(source)
    print(path)
