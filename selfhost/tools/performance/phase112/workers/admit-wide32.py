#!/usr/bin/env python3
"""Exact optional direct32+CPU-failstop admission; no compiler/target execution."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import sys

BASE_METHOD_SHA = '8450e9e120574e1dc5a4dca51f4860258516aa1b0c2eef9e6f9313ea98ff93d9'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime-source', type=Path, required=True)
    parser.add_argument('--runtime-object', type=Path, required=True)
    parser.add_argument('--compiler', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    here = Path(__file__).resolve().parent
    base_path = here / 'admit-failstop.py'
    if hashlib.sha256(base_path.read_bytes()).hexdigest() != BASE_METHOD_SHA:
        raise SystemExit('Refused: original direct8 admission implementation changed')
    sys.dont_write_bytecode = True
    spec = importlib.util.spec_from_file_location('p112_failstop_admission', base_path)
    base = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(base)
    source, obj, compiler = map(base.pin, [args.runtime_source, args.runtime_object, args.compiler])
    if source['sha256'] != base.SOURCE_SHA or obj['sha256'] != base.OBJECT_SHA:
        raise SystemExit('Refused: exact selected CPU runtime04 source/object required')
    modules = [here / name for name in base.MODULES] + [here / 'wide32-entry.bend']
    expected = {}
    for module in modules:
        expected.update(base.declarations(module.read_text()))
    verifier = here.parents[1] / 'phase111' / 'segment' / 'verify.bend'
    expected.update(base.declarations(verifier.read_text()))
    actual = base.declarations(args.compiler.read_text())
    mismatches = [name for name, body in expected.items() if actual.get(name) != body]
    extras = [name for name in actual if name[1].startswith(('p112t_', 'p112q_', 'p112w_', 'p112f_')) and name not in expected]
    if mismatches or extras:
        raise SystemExit('Refused: exact wide32 declaration mismatch: ' + repr(mismatches + extras))
    if args.out.exists():
        raise SystemExit('Refused: admission output already exists')
    args.out.mkdir(parents=True)
    record = dict(kind='phase112-cpu-failstop-worker-admission', profile='direct32-failstop',
                  admitted=True, targetsExecuted=False, runtimeSource=source, runtimeObject=obj,
                  compiler=compiler, method=base.pin(__file__), baseMethod=base.pin(base_path),
                  modules=[base.pin(module) for module in modules], originalVerifier=base.pin(verifier),
                  exactDeclarations=len(expected),
                  declarationHashes={kind + ' ' + name: hashlib.sha256(body.encode()).hexdigest()
                                     for (kind, name), body in expected.items()},
                  contract=dict(abiVersion=11101, capabilities=1, threads=1, gpu='off',
                                privateArityMax=32, dependencyPasses=3, resultWords=1,
                                failureCodes=list(range(1, 9)), failureReturnUnreachable=True,
                                secondaryRuntimePointers='exact scratch',
                                failureFrames='only inside complete terminal failure suffix',
                                continuationFusion=False),
                  limitations=['Root must require these compiler and runtime object hashes at execution.',
                               'No DEVICE, alternative runtime, or continuation-fusion admission.',
                               'This data gate does not execute source/native controls.'])
    (args.out / 'manifest.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(dict(admitted=True, profile=record['profile'], compiler=compiler['sha256'])))


if __name__ == '__main__':
    main()
