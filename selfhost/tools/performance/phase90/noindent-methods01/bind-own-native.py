#!/usr/bin/env python3
"""Bind actual own-backend C emission and guarded Clang build; no targets."""
import argparse
import json
import sys
from pathlib import Path
sys.dont_write_bytecode = True
from own_native_support import bind_build, pin

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('emission', type=Path)
parser.add_argument('guard', type=Path)
parser.add_argument('image', type=Path)
args = parser.parse_args()
result = bind_build(args.emission, args.guard, args.image)
destination = Path(str(args.image.resolve())+'.own-build.json')
with destination.open('x') as stream:
    json.dump(result, stream, indent=2);stream.write('\n')
print(json.dumps(dict(receipt=pin(destination), source=result['source'], provenance=result['provenance'],
                      targetsExecuted=False, nativeB2Qualified=False, cacheAdmitted=False)))
