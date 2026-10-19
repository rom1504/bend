#!/usr/bin/env python3
"""Materialize diagnostic-only counters over the pinned Phase111 runtime04."""
import argparse
import hashlib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
SOURCE = ROOT / 'selfhost/build/phase111/runtime-source04'
SOURCE_SHA = 'c0fc18aabb2749cc85b5040c29756d8d73d90b73bb954d10ed1d0d410528aa50'
PUBLIC = ['keep', 'sink', 'tag', 'ctor', 'take', 'closure', 'frame', 'jump',
          'return', 'apply', 'stack_pop', 'stack_get', 'reg_get', 'fail', 'op',
          'special_ctor', 'special_test', 'special_take']
HEAP = ['heap_alloc', 'heap_alloc_miss', 'heap_free', 'spare_free', 'rfc_wrap',
        'rfc_seal', 'rfc_view', 'rfc_bump', 'term_keep', 'term_sink', 'term_drop', 'ctr_take']
COUNTERS = ['rt_' + n for n in PUBLIC] + ['set_regs', 'register_words_copied',
    'register_words_zeroed'] + ['bank_' + n + '_words' for n in
    ['init', 'read', 'write', 'save', 'take']] + HEAP
# IDs are public semantic metadata, not sampled native addresses.
HISTOGRAMS = {
    'dispatch_fid': (65536, 'fid'), 'jump_fid': (65536, 'fid'),
    'closure_fid': (65536, 'fid'), 'apply_fid': (65536, 'fid'),
    'frame_fid': (65536, 'fid'), 'public_calls_fid': (65536, 'fid'),
    'op': (86, 'op'), 'ctor_cid': (65536, 'cid'), 'take_cid': (65536, 'cid'),
    'ctor_arity': (257, 'arity'), 'take_arity': (257, 'arity'),
    'frame_captures': (257, 'arity'), 'jump_arity': (257, 'arity'),
    'return_width': (257, 'arity'), 'closure_captures': (257, 'arity'),
    'special_ctor_kind': (10, 'kind'), 'special_test_kind': (10, 'kind'),
    'special_take_kind': (10, 'kind'), 'heap_alloc_class': (64, 'class'),
    'heap_free_class': (64, 'class'), 'ctr_take_arity': (257, 'arity')}


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--heap-rc', action='store_true')
    args = parser.parse_args()
    out = args.out.resolve()
    if out.exists():
        raise SystemExit('refusing existing output directory')
    original = (SOURCE / 'runtime.c').read_text()
    if hashlib.sha256(original.encode()).hexdigest() != SOURCE_SHA:
        raise SystemExit('pinned runtime04 source mismatch')
    text = original
    patches = []

    def replace(label, old, new):
        nonlocal text
        if text.count(old) != 1:
            raise ValueError(f'{label}: expected one exact patch, found {text.count(old)}')
        text = text.replace(old, new)
        patches.append(dict(label=label, old=old, new=new, occurrences=1))

    def entry(name, statements):
        matches = list(re.finditer(r'^(?:(?:static|INLINE|OUTLINE|FAR)\s+)?'
                                  r'(?:void|uint64_t|Loc|Term|u64)\s+' + re.escape(name) +
                                  r'\([^;{}]*\)\s*\{', text, re.M))
        if len(matches) != 1:
            raise ValueError(f'{name}: expected one definition, found {len(matches)}')
        old = matches[0].group()
        replace(name, old, old + '\n  ' + statements + '\n')

    replace('diagnostic-header', '#include "runtime.h"',
            '#include "runtime.h"\n#include "p112-counters.h"')
    for name in PUBLIC:
        extra = {
            'ctor': 'P112_HIT(ctor_cid, cid); P112_HIT(ctor_arity, count);',
            'take': 'P112_HIT(take_cid, term_aux(term)); P112_HIT(take_arity, count);',
            'closure': 'P112_HIT(closure_fid, fid); P112_HIT(closure_captures, count);',
            'frame': 'P112_HIT(frame_fid, next_fid); P112_HIT(frame_captures, count);',
            'jump': 'P112_HIT(jump_fid, fid); P112_HIT(jump_arity, count);',
            'return': 'P112_HIT(return_width, count);',
            'apply': 'P112_HIT(apply_fid, term_aux(closure));',
            'op': 'P112_HIT(op, op);',
            'special_ctor': 'P112_HIT(special_ctor_kind, kind);',
            'special_test': 'P112_HIT(special_test_kind, kind);',
            'special_take': 'P112_HIT(special_take_kind, kind);',
        }.get(name, '')
        entry('p111_rt_' + name, 'P112_ADD(rt_' + name + ', 1); '
              'P112_HIT(public_calls_fid, p112_current_fid); ' + extra)
    entry('p111_set_regs', 'P112_ADD(set_regs, 1);')
    replace('register-word-accounting',
            '  if (count) memmove(state->regs, values, count * sizeof(uint64_t));',
            '  P112_ADD(register_words_copied, count);\n'
            '  P112_ADD(register_words_zeroed, p111_transport_words - count);\n'
            '  if (count) memmove(state->regs, values, count * sizeof(uint64_t));')
    for macro, name in [('INIT_BANK', 'init'), ('READ_STATE(V)', 'read'),
                        ('WRITE_STATE(V)', 'write'), ('SAVE(V)', 'save'),
                        ('TAKE(V)', 'take')]:
        old = re.search(r'^#define WL_' + re.escape(macro) + r' .+$', text, re.M).group()
        head, body = old.split(' ', 2)[1:]
        replace('bank-' + name, old, '#define ' + head +
                ' P112_ADD(bank_' + name + '_words, p111_transport_words); ' + body)
    replace('dispatch-fid', '    Fid next = state.next;\n',
            '    Fid next = state.next;\n'
            '    p112_current_fid = next; P112_HIT(dispatch_fid, next);\n')
    # Only start after successful descriptor binding. No instrumentation can
    # report successfully if normal runtime startup/execution exits nonzero.
    replace('register-exit-report', '  p111_bind(program);\n',
            '  p111_bind(program);\n  p112_start();\n')
    if args.heap_rc:
        for name in HEAP:
            extra = {
                'heap_alloc': ' P112_HIT(heap_alloc_class, cls);',
                'heap_free': ' P112_HIT(heap_free_class, cls);',
                'ctr_take': ' P112_HIT(ctr_take_arity, n);',
            }.get(name, '')
            entry(name, 'P112_ADD(' + name + ', 1);' + extra)
    support = (HERE / 'support.inc.c').read_text()
    suffix = '\n/* Phase112 diagnostic-only report implementation. */\n' + support
    materialized = text + suffix
    inverse = materialized[:-len(suffix)]
    for patch in reversed(patches):
        if inverse.count(patch['new']) != 1:
            raise ValueError('inverse patch is not unique: ' + patch['label'])
        inverse = inverse.replace(patch['new'], patch['old'])
    assert inverse == original, 'diagnostic transport changed unrecorded source bytes'

    header = ['#ifndef P112_COUNTERS_H', '#define P112_COUNTERS_H',
              '#include <stdint.h>', '#include <stddef.h>',
              '#define P112_SOURCE_SHA "' + SOURCE_SHA + '"',
              '#define P112_HEAP_RC ' + str(int(args.heap_rc)),
              'static uint32_t p112_current_fid = 65535;',
              'static uint64_t p112_invalid;',
              'enum { ' + ', '.join('P112_C_' + n for n in COUNTERS) + ', P112_C_COUNT };',
              'static uint64_t p112_counters[P112_C_COUNT];',
              'static const char *const p112_counter_names[] = {' +
              ','.join(json.dumps(n) for n in COUNTERS) + '};',
              'static inline void p112_add(uint64_t *counter, uint64_t amount) {',
              '  uint64_t before = *counter; *counter += amount;',
              '  if (*counter < before) p112_invalid = 1;', '}',
              '#define P112_ADD(N,V) p112_add(&p112_counters[P112_C_##N], (V))',
              '#define P112_HIT(N,V) do { uint64_t p112_i_ = (V); \\\n'
              '  if (p112_i_ < sizeof(p112_h_##N)/sizeof(uint64_t)) \\\n'
              '    p112_add(&p112_h_##N[p112_i_], 1); else p112_invalid = 1; } while (0)']
    header += ['static uint64_t p112_h_' + name + '[' + str(size) + '];'
               for name, (size, _) in HISTOGRAMS.items()]
    header += ['typedef struct { const char *name, *kind; uint64_t *bins; uint32_t count; } P112Hist;',
               'static P112Hist p112_histograms[] = {']
    header += ['  {"' + name + '","' + kind + '",p112_h_' + name + ',' + str(size) + '},'
               for name, (size, kind) in HISTOGRAMS.items()]
    header += ['};', 'static void p112_start(void);', '#endif', '']
    out.mkdir(parents=True)
    (out / 'runtime.c').write_text(materialized)
    (out / 'p112-counters.h').write_text('\n'.join(header))
    for name in ['runtime.h', 'primitives.h']:
        (out / name).write_bytes((SOURCE / name).read_bytes())
    manifest = dict(kind='phase112-diagnostic-runtime', version=1,
        diagnosticOnly=True, targetsRun=False, heapRc=args.heap_rc,
        source=pin(SOURCE / 'runtime.c'), sourceManifest=pin(SOURCE / 'manifest.json'),
        tools=[pin(Path(__file__)), pin(HERE / 'support.inc.c')],
        output=[pin(out / name) for name in ['runtime.c', 'runtime.h', 'primitives.h', 'p112-counters.h']],
        exactInverseVerified=True, patches=patches, counters=COUNTERS,
        histograms={name: dict(size=size, kind=kind) for name, (size, kind) in HISTOGRAMS.items()},
        limitations=['single sequential CPU only', 'instrumented times are not benchmark results',
                    'nested helper counters are not disjoint costs',
                    'missing report, overflow, nonzero exit, or changed stdout/stderr must fail validation'])
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(json.dumps(dict(out=str(out), patches=len(patches), inverseVerified=True,
                          counterBytes=8 * (len(COUNTERS) + sum(s for s, _ in HISTOGRAMS.values())))))


if __name__ == '__main__':
    main()
