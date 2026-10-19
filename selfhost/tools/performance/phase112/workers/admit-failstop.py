#!/usr/bin/env python3
"""Data-only binding of the optional CPU fail-stop worker profile; runs no target."""
import argparse
import hashlib
import json
import re
from pathlib import Path

SOURCE_SHA = 'c0fc18aabb2749cc85b5040c29756d8d73d90b73bb954d10ed1d0d410528aa50'
OBJECT_SHA = '560bbec83395b6a4b2be247e14b362fc1e803ee0a86c680f3797d895ed67c23e'
MODULES = ['model.bend', 'plan.bend', 'emit.bend', 'side-exit.bend', 'side-exit-entry.bend',
           'runtime-safe.bend', 'runtime-safe-entry.bend', 'direct-model.bend', 'direct-plan.bend',
           'direct-emit.bend', 'direct-entry.bend', 'direct-failstop.bend', 'direct-failstop-entry.bend']
DECL = re.compile(r'^(?:@unsafe\n)?(def|type|law) ([A-Za-z0-9_.]+)\b', re.M)


def pin(path):
    path = Path(path).resolve()
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def code(text):
    # The composer moves full-line comments at declaration boundaries. No code,
    # string contents, inline text, indentation or token order is normalized.
    return '\n'.join(line.rstrip() for line in text.splitlines()
                     if line.strip() and not line.lstrip().startswith('#'))


def declarations(text):
    found = list(DECL.finditer(text))
    out = {}
    for i, match in enumerate(found):
        key = (match.group(1), match.group(2))
        if key in out:
            raise SystemExit('Refused: duplicate declaration ' + str(key))
        end = found[i + 1].start() if i + 1 < len(found) else len(text)
        out[key] = code(text[match.start():end])
    return out


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime-source', type=Path, required=True)
    parser.add_argument('--runtime-object', type=Path, required=True)
    parser.add_argument('--compiler', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    source, obj, compiler = map(pin, [args.runtime_source, args.runtime_object, args.compiler])
    if source['sha256'] != SOURCE_SHA or obj['sha256'] != OBJECT_SHA:
        raise SystemExit('Refused: optional fail-stop profile requires exact selected CPU runtime04 source and object')
    here = Path(__file__).resolve().parent
    expected = {}
    for name in MODULES:
        expected.update(declarations((here / name).read_text()))
    verifier = here.parents[1] / 'phase111' / 'segment' / 'verify.bend'
    expected.update(declarations(verifier.read_text()))
    actual = declarations(args.compiler.read_text())
    mismatches = [name for name, body in expected.items() if actual.get(name) != body]
    unexpected = [name for name in actual if name[1].startswith(('p112t_', 'p112q_', 'p112w_')) and name not in expected]
    if mismatches or unexpected:
        raise SystemExit('Refused: exact final worker/verifier declaration mismatch: ' + repr(mismatches + unexpected))
    if args.out.exists():
        raise SystemExit('Refused: admission output already exists')
    args.out.mkdir(parents=True)
    record = dict(kind='phase112-cpu-failstop-worker-admission', admitted=True, targetsExecuted=False,
                  runtimeSource=source, runtimeObject=obj, compiler=compiler, method=pin(__file__),
                  modules=[pin(here / name) for name in MODULES],
                  originalVerifier=pin(verifier), exactDeclarations=len(expected),
                  declarationHashes={kind + ' ' + name: hashlib.sha256(body.encode()).hexdigest()
                                     for (kind, name), body in expected.items()},
                  contract=dict(abiVersion=11101, capabilities=1, threads=1, gpu='off',
                                failureCodes=list(range(1, 9)), failureReturnUnreachable=True,
                                secondaryRuntimePointers='exact scratch',
                                failureFrames='only inside complete terminal failure suffix'),
                  limitations=['Source/data admission does not run the compiler or native controls.',
                               'Runner must require the pinned compiler and runtime object bytes.',
                               'No DEVICE, asynchronous-error, or alternative-runtime claim.'])
    (args.out / 'manifest.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(dict(admitted=True, compiler=compiler['sha256'], runtimeObject=obj['sha256'])))


if __name__ == '__main__':
    main()
