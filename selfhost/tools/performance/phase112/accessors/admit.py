#!/usr/bin/env python3
"""Authenticate accessor source/ABI and unchanged verifier; run no targets."""
import argparse
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
BASE = ROOT / 'selfhost/build/phase111/full-source05/compiler.bend'


def digest(text):
    return hashlib.sha256(text.encode()).hexdigest()


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def declaration(source, name):
    matches = list(re.finditer(r'(?m)^(?:@unsafe\n)?def ' + re.escape(name) + r'\(', source))
    if len(matches) != 1:
        raise ValueError('Missing or repeated declaration: ' + name)
    start = matches[0].start()
    end = source.find('\n\n', start)
    return source[start:end if end >= 0 else len(source)].strip()


def exact_definitions(source, module):
    for name in re.findall(r'(?m)^def ([A-Za-z0-9_.]+)\(', module):
        if declaration(source, name) != declaration(module, name):
            raise ValueError('Changed audited declaration: ' + name)


def validate(source, runtime, header, mode, specials, abi):
    if digest(runtime) != abi['runtimeSha256']:
        raise ValueError('Requires the exact qualified runtime04 source')
    if digest(header) != abi['headerSha256']:
        raise ValueError('Requires the exact ABI11101 header/layout assertions')
    base = BASE.read_text()
    if digest(base) != abi['baselineSha256']:
        raise ValueError('Frozen Phase111 baseline changed')
    verify = (ROOT / 'selfhost/tools/performance/phase111/segment/verify.bend').read_text()
    if digest(verify) != abi['verifierSha256']:
        raise ValueError('Verifier source changed; re-audit required')
    exact_definitions(source, verify)
    for name in ['p111_emit_lowered', 'p111_emit_admitted', 'p111_emit_plan',
                 'p111_compile_prepared', 'p111_compile_source', 'p111q_stmts_head']:
        if declaration(source, name) != declaration(base, name):
            raise ValueError('Changed checked rendering boundary: ' + name)
    if mode == 'none':
        if declaration(source, 'p111q_stmt') != declaration(base, 'p111q_stmt'):
            raise ValueError('Unexpected accessor renderer in none mode')
    else:
        for name in ['original.bend', 'emit.bend', 'entry-' + mode + '.bend']:
            exact_definitions(source, (HERE / name).read_text())
        original = declaration(source, 'p112a_original_stmt').replace('def p112a_original_stmt(', 'def p111q_stmt(', 1)
        if original != declaration(base, 'p111q_stmt'):
            raise ValueError('Original renderer fallback is not exact')
    if specials:
        exact_definitions(source, (HERE / 'special-tests.bend').read_text())
        original = declaration(source, 'p112_special_test_fallback').replace('def p112_special_test_fallback(', 'def p111_test(', 1)
        if original != declaration(base, 'p111_test'):
            raise ValueError('Original special-test fallback is not exact')
    elif declaration(source, 'p111_test') != declaration(base, 'p111_test'):
        raise ValueError('Unexpected special-test override')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--runtime', type=Path, default=ROOT / 'selfhost/build/phase111/runtime-source04/runtime.c')
    parser.add_argument('--mode', choices=['none', 'tag', 'registers', 'both'], required=True)
    parser.add_argument('--special-tests', action='store_true')
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase112'):
        raise ValueError('Use a fresh Phase112 receipt directory')
    abi_path = HERE / 'abi.json'
    abi = json.loads(abi_path.read_text())
    source, runtime = args.source.read_text(), args.runtime.read_text()
    header_path = args.runtime.with_name('runtime.h')
    header = header_path.read_text()
    validate(source, runtime, header, args.mode, args.special_tests, abi)
    # These are mutations of reflected source data, never executable targets.
    variants = [
        ('runtime-byte-change', source, runtime + '\n', header),
        ('term-aux-offset', source, runtime.replace('return (t >> 40) & 0xFFFF;', 'return (t >> 39) & 0xFFFF;', 1), header),
        ('abi-version', source, runtime, header.replace('11101', '11102', 1)),
        ('register-offset', source, runtime, header.replace('regs) == 40', 'regs) == 48', 1)),
        ('register-bound', source.replace('u => U32.is_lt(id,nt_choose', 'u => U32.is_le(id,nt_choose', 1), runtime, header),
        ('skip-verifier', source.replace('p111_emit_verified(program,p111_verify_program(program))', 'p111_emit_verified(program,"")', 1), runtime, header),
    ]
    results = []
    for name, src, rt, hdr in variants:
        if (src, rt, hdr) == (source, runtime, header):
            raise ValueError('Mutation did not apply: ' + name)
        try:
            validate(src, rt, hdr, args.mode, args.special_tests, abi)
        except ValueError as error:
            results.append(dict(name=name, refused=True, error=str(error)))
        else:
            raise ValueError('Mutation unexpectedly admitted: ' + name)
    paths = [Path(__file__), abi_path, BASE, args.source, args.runtime, header_path,
             ROOT / 'selfhost/tools/performance/phase111/segment/verify.bend']
    if args.mode != 'none':
        paths += [HERE / name for name in ['original.bend', 'emit.bend', 'entry-' + args.mode + '.bend']]
    if args.special_tests:
        paths.append(HERE / 'special-tests.bend')
    inputs = [pin(p) for p in paths]
    report = dict(kind='phase112-accessor-source-admission', complete=True, targetsRun=False,
                  abiVersion=11101, mode=args.mode, specialTests=args.special_tests,
                  inputs=inputs, source=pin(args.source), runtime=pin(args.runtime),
                  refusals=results, publicVerifierUnchanged=True,
                  scope='Exact source/ABI authentication only. Root must bind the compiled runtime object and execute semantic controls separately.')
    for item in inputs:
        if pin(item['file']) != item:
            raise ValueError('Input changed during admission')
    out.mkdir(parents=True)
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, refusals=len(results), report=str(out / 'report.json'))))


if __name__ == '__main__':
    main()
