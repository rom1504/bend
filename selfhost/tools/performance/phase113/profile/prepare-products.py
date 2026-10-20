#!/usr/bin/env python3
"""Add the qualified product helper to unchanged Phase112 counter instrumentation.

Source preparation only. The unchanged Phase112 runner compiles and qualifies it.
"""
import argparse
import contextlib
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
OLD = ROOT/'selfhost/tools/performance/phase112/profile'
PRODUCTS = HERE.parent/'products'
spec = importlib.util.spec_from_file_location('phase112_counter_prepare', OLD/'prepare.py')
legacy = importlib.util.module_from_spec(spec)
spec.loader.exec_module(legacy)


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def verify(record):
    if pin(record['file']) != record:
        raise ValueError('Changed input: ' + record['file'])


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--production-source', type=Path,
                   default=ROOT/'selfhost/build/phase113/runtime-products01')
    p.add_argument('--production-build', type=Path,
                   default=ROOT/'selfhost/build/phase113/runtime-products-build01/report.json')
    a = p.parse_args()
    out = a.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase113'):
        raise ValueError('Fresh Phase113 source directory required')
    source = a.production_source.resolve()
    production = json.loads((source/'manifest.json').read_text())
    build = json.loads(a.production_build.read_text())
    if (production.get('kind') != 'phase113-array-pair-runtime-source' or
            not production.get('complete') or not production.get('exactRuntime04Prefix') or
            build.get('kind') != 'phase113-array-pair-runtime-build' or
            not build.get('complete') or build.get('exitCode') != 0):
        raise ValueError('Complete additive production source/build required')
    expected = {row['file']: row for row in production['outputs']}
    build_inputs = {row['file']: row for row in build['inputs']}
    for name in ['runtime.c', 'runtime.h', 'primitives.h']:
        row = pin(source/name)
        if expected.get(row['file']) != row or build_inputs.get(row['file']) != row:
            raise ValueError('Production build must bind exact materialized source: ' + name)
    helper = (PRODUCTS/'runtime.inc.c').read_bytes()
    header = (PRODUCTS/'runtime-header.inc.h').read_bytes()
    base = legacy.SOURCE
    if (source/'runtime.c').read_bytes() != (base/'runtime.c').read_bytes() + b'\n' + helper:
        raise ValueError('Production source is not exact runtime04 plus exact helper')
    if (source/'runtime.h').read_bytes() != (base/'runtime.h').read_bytes() + header:
        raise ValueError('Production header is not the exact additive header')
    if (source/'primitives.h').read_bytes() != (base/'primitives.h').read_bytes():
        raise ValueError('Primitive declarations changed')
    inputs = [pin(__file__), pin(source/'manifest.json'), pin(a.production_build),
              build['object'], *production['inputs'], *production['outputs'],
              *[pin(OLD/name) for name in ['prepare.py', 'run.py', 'parse.py',
                                           'support.inc.c', 'control-freeze.json']]]
    inputs = list({row['file']: row for row in inputs}.values())
    for row in inputs:
        verify(row)
    argv = sys.argv
    try:
        sys.argv = [str(OLD/'prepare.py'), '--out', str(out), '--heap-rc']
        with contextlib.redirect_stdout(io.StringIO()):
            legacy.main()
    finally:
        sys.argv = argv
    manifest = json.loads((out/'manifest.json').read_text())
    instrumented = (out/'runtime.c').read_bytes()
    composed = instrumented + b'\n' + helper
    suffix = b'\n/* Phase112 diagnostic-only report implementation. */\n' + (OLD/'support.inc.c').read_bytes()
    if not instrumented.endswith(suffix) or composed.count(suffix) != 1:
        raise ValueError('Unexpected legacy diagnostic support placement')
    inverse = composed.replace(suffix, b'', 1)
    for patch in reversed(manifest['patches']):
        old, new = patch['old'].encode(), patch['new'].encode()
        if inverse.count(new) != 1:
            raise ValueError('Nonunique inverse patch: ' + patch['label'])
        inverse = inverse.replace(new, old)
    if inverse != (source/'runtime.c').read_bytes():
        raise ValueError('Removing diagnostics must recover exact qualified production source')
    (out/'runtime.c').write_bytes(composed)
    (out/'runtime.h').write_bytes((source/'runtime.h').read_bytes())
    for row in inputs:
        verify(row)
    manifest.update(
        extension='phase113-qualified-array-pair', extensionVersion=1,
        productionSource=pin(source/'runtime.c'), productionHeader=pin(source/'runtime.h'),
        productionSourceManifest=pin(source/'manifest.json'),
        productionBuild=pin(a.production_build), productionObject=build['object'],
        inputs=inputs, exactProductionInverseVerified=True,
        inverseVerifiedAgainst='productionSource',
        baseInstrumentation=dict(bytes=len(instrumented),
                                 sha256=hashlib.sha256(instrumented).hexdigest()),
        additiveHelper=pin(PRODUCTS/'runtime.inc.c'),
        additiveHeader=pin(PRODUCTS/'runtime-header.inc.h'),
        output=[pin(out/name) for name in ['runtime.c', 'runtime.h', 'primitives.h', 'p112-counters.h']],
        metadataScope='Legacy source/sourceSha256 identifies the common runtime04 instrumentation prefix. productionSource and output authenticate the complete additive translation unit.',
        limitations=manifest['limitations'] + [
            'p113_rt_array_pair has no new entry/op histogram; existing underlying heap/RC hooks remain unchanged',
            'op/public-call reductions count bypassed generic entry points, not eliminated logical array operations',
            'current-fid histograms follow runtime dispatch context, not necessarily a directly called function',
            'root must run the unchanged independent counter control and all product output gates',
            'counts include initial output evaluation plus one repetition; instrumented time is not performance evidence'])
    (out/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    print(json.dumps(dict(complete=True, targetsRun=False, out=str(out),
                          exactProductionInverseVerified=True, manifest=pin(out/'manifest.json'))))


if __name__ == '__main__':
    main()
