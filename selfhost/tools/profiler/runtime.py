#!/usr/bin/env python3
"""Materialize an opt-in diagnostic native runtime and a root-owned build plan.

No compilation or target execution occurs here. Input manifests pin an existing
runtime source, its quoted headers, and optionally a retained program object.
Every insertion must match exactly once; reverse replacement must reproduce the
complete original runtime bytes. Production sources and artifacts are untouched.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent


def pin(path):
    path = Path(path).resolve()
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=digest.hexdigest())


def verify(item):
    actual = pin(item['file'])
    if any(actual[key] != item[key] for key in ('sha256', 'bytes')):
        raise ValueError('Frozen input changed: ' + item['file'])
    return Path(actual['file'])


def changes():
    rows = [
        ('support', '// Dialect\n// =======\n',
         '#include "runtime-support.inc.c"\n\n// Dialect\n// =======\n'),
        ('bind', '  p111_program_active = program;\n',
         '  p111_program_active = program;\n'
         '  bend_profile_initialize((uint32_t)program->segment_count, program->segments);\n'),
        ('dispatch', '    Reply reply = run(&state);\n',
         '    uint32_t bend_profile_previous = bend_profile_dispatch_enter(next);\n'
         '    Reply reply = run(&state);\n'
         '    bend_profile_dispatch_leave(bend_profile_previous);\n'),
    ]
    hooks = [
        ('heap-alloc', 'INLINE Loc heap_alloc(Env e, Cls cls) {',
         'BP_ALLOC, 1', 'BP_ALLOC_WORDS, UINT64_C(1) << cls'),
        ('heap-refill', 'OUTLINE Loc heap_alloc_miss(Env e, Cls cls) {',
         'BP_ALLOC_MISS, 1'),
        ('heap-free', 'INLINE void heap_free(Env e, Cls cls, Loc loc) {',
         'BP_FREE, 1', 'BP_FREE_WORDS, UINT64_C(1) << cls'),
        ('keep', 'INLINE Term term_keep(Env e, Term t) {', 'BP_KEEP, 1'),
        ('sink', 'INLINE void term_sink(Env e, Term t) {', 'BP_SINK, 1'),
        ('drop', 'FAR void term_drop(Env e, Term t) {', 'BP_DROP, 1'),
        ('take', 'INLINE Loc ctr_take(Env e, Term t, u32 n, THR Term* out) {', 'BP_TAKE, 1'),
        ('frame', 'uint64_t p111_rt_frame(P111State *state, uint32_t next_fid, const uint64_t *captures, uint32_t count) {',
         'BP_FRAME, 1', 'BP_FRAME_WORDS, count'),
        ('return', 'uint64_t p111_rt_return(P111State *state, const uint64_t *values, uint32_t count) {',
         'BP_RETURN, 1'),
        ('primitive', 'uint64_t p111_rt_op(P111State *state, uint32_t op, const uint64_t *args, uint32_t count) {',
         'BP_PRIMITIVE, 1'),
        ('register-transport', 'static void p111_set_regs(P111State *state, const uint64_t *values, uint32_t count) {',
         'BP_REG_COPY_WORDS, count',
         'BP_REG_CLEAR_WORDS, (p111_program_active->capabilities & UINT64_C(4)) ? 0 : p111_transport_words - count'),
    ]
    for label, signature, *events in hooks:
        old = signature + '\n'
        new = old + ''.join('  bend_profile_count(' + event + ');\n' for event in events)
        rows.append((label, old, new))
    return rows


def materialize(original):
    text = original.decode('utf-8')
    transformed = text
    applied = []
    for label, old, new in changes():
        if transformed.count(old) != 1:
            raise ValueError('Required unique runtime hook absent or ambiguous: ' + label)
        if new in transformed:
            raise ValueError('Runtime is already instrumented: ' + label)
        transformed = transformed.replace(old, new, 1)
        applied.append(dict(label=label, original=old, diagnostic=new, occurrences=1))
    recovered = transformed
    for row in reversed(applied):
        if recovered.count(row['diagnostic']) != 1:
            raise ValueError('Ambiguous reverse hook: ' + row['label'])
        recovered = recovered.replace(row['diagnostic'], row['original'], 1)
    if recovered.encode('utf-8') != original:
        raise ValueError('Diagnostic reversibility check failed')
    return transformed.encode('utf-8'), applied


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--manifest', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    manifest_path = args.manifest.resolve()
    manifest = json.loads(manifest_path.read_text())
    runtime = verify(manifest['runtime'])
    headers = [verify(item) for item in manifest['headers']]
    original = runtime.read_bytes()
    diagnostic, edits = materialize(original)
    includes = set(re.findall(rb'^#include "([^"\n]+)"', original, flags=re.M))
    header_names = [path.name for path in headers]
    if len(set(header_names)) != len(header_names):
        raise ValueError('Duplicate header basenames are unsupported')
    if includes != {name.encode() for name in header_names}:
        raise ValueError('Manifest must pin exactly the runtime quoted headers')
    support = HERE / 'runtime-support.inc.c'
    compiler = Path(shutil.which(manifest.get('compiler', 'gcc')) or '').resolve()
    if not compiler.is_file():
        raise ValueError('C compiler is unavailable')
    linker = Path(shutil.which(manifest.get('linker', 'gcc')) or '').resolve()
    if not linker.is_file():
        raise ValueError('Linker driver is unavailable')
    flags = manifest.get('compileFlags', ['-O2', '-std=gnu11', '-ffp-contract=off'])
    if not isinstance(flags, list) or not all(isinstance(x, str) for x in flags):
        raise ValueError('compileFlags must be an argv array')
    program = verify(manifest['programObject']) if 'programObject' in manifest else None
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    (out / 'runtime.c').write_bytes(diagnostic)
    (out / support.name).write_bytes(support.read_bytes())
    for header in headers:
        (out / header.name).write_bytes(header.read_bytes())
    (out / 'method.py').write_bytes(Path(__file__).read_bytes())
    (out / 'edits.json').write_text(json.dumps(edits, indent=2) + '\n')
    jobs = [dict(label='compile-runtime', command=[str(compiler), *flags, '-c',
                 str(out / 'runtime.c'), '-o', str(out / 'runtime.o')])]
    if program:
        jobs.append(dict(label='link-diagnostic', command=[str(linker), '-no-pie',
            str(program), str(out / 'runtime.o'), '-pthread', '-lm',
            '-Wl,--export-dynamic-symbol=bend_profile_dispatch_get',
            '-Wl,--export-dynamic-symbol=bend_profile_dispatch_id',
            '-o', str(out / 'program')]))
    report = dict(schema='bend-native-profile-runtime-plan-v1', complete=True,
        compiled=False, executed=False, reverseExact=True,
        inputs=[pin(manifest_path), pin(runtime), *[pin(x) for x in headers],
                pin(support), pin(__file__), pin(compiler), pin(linker),
                *([pin(program)] if program else [])],
        outputs=[pin(out / name) for name in ['runtime.c', support.name,
                 'method.py', 'edits.json', *header_names]], jobs=jobs,
        context=dict(getter='bend_profile_dispatch_get', getterResult='uint32_t',
            unknown=4294967295, storage='initial-exec TLS lock-free atomic uint32',
            globalSymbol='bend_profile_dispatch_id', globalScope='one active dispatch thread only',
            meaning='Active dispatcher segment; private calls retain outer segment; not logical ancestry'),
        environment=dict(BEND_PROFILE_EVENTS_OUT='Fresh event JSON path; exclusive create',
            BEND_PROFILE_COUNTERS='0: context only; 1: count runtime events (default with output path)'),
        scope='Diagnostic runtime-only relink; generated program object and P111 ABI unchanged. '
              'Semantic equivalence, signal-safe getter machine inspection and overhead require separate execution gates.')
    for item in report['inputs']:
        verify(item)
    (out / 'plan.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, reverseExact=True, plan=str(out / 'plan.json'), jobs=len(jobs))))


if __name__ == '__main__':
    main()
