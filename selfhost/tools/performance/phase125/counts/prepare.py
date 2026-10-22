"""Derive counter-only Phase118 runtime source; never build or execute a target."""
import argparse
import hashlib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
PARENT = ROOT / 'selfhost/build/phase118/runtime-extend01'
PINS = {
    'runtime.c': '371f58c5d47db192fc1bbe38e990057af2145a0bccfb733062c08896c9c09f35',
    'runtime.h': '9b19b8d6ae1c8f07759041201c2692c20d9612393819e2bbc597deba44679d12',
    'primitives.h': 'ecbdfe62b875fc20e5805840b83c3779ed8fb8fb1de83c543ba1ce1217165d20',
}
COUNTERS = ['heap_alloc_calls', 'constructor_cells', 'ctr_take_calls',
            'ctr_take_fields', 'ctr_take_wrapped_calls', 'extend_generic_calls',
            'extend_sized_calls', 'extend1_calls']


def pin(path):
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    assert not out.exists(), 'refuse existing destination'
    assert out.is_relative_to(ROOT / 'selfhost/build/phase125'), 'isolated Phase125 build destination required'
    parent_receipt = json.loads((PARENT / 'report.json').read_text())
    assert parent_receipt['complete'] and parent_receipt['status'] == 0
    assert pin(PARENT / 'runtime.c') == parent_receipt['source']
    for name, digest in PINS.items():
        assert pin(PARENT / name)['sha256'] == digest, name
    original = (PARENT / 'runtime.c').read_text()
    # All ten source use sites (two are sized macro templates) were audited:
    # each materializes exactly one preceding fresh heap_alloc constructor cell.
    ctor_sites = [dict(line=i, text=line.strip()) for i, line in enumerate(original.splitlines(), 1)
                  if 'term_ctr(' in line and not line.startswith('#define term_ctr(')]
    assert len(ctor_sites) == 10
    text = original
    patches = []

    def replace(label, old, new):
        nonlocal text
        assert text.count(old) == 1, (label, text.count(old))
        text = text.replace(old, new)
        patches.append(dict(label=label, old=old, new=new, occurrences=1))

    replace('include', '#include "runtime.h"', '#include "runtime.h"\n#include "p125-counts.h"')
    replace('heap-allocation', 'INLINE Loc heap_alloc(Env e, Cls cls) {',
            'INLINE Loc heap_alloc(Env e, Cls cls) {\n  P125_ADD(heap_alloc_calls, 1);')
    replace('constructor-materialization', '#define term_ctr(cid, loc) term_make(TAG_CTR, cid, loc)',
            'INLINE Term p125_counted_ctr(u64 cid, Loc loc) {\n'
            '  P125_ADD(constructor_cells, 1); P125_HIT(p125_ctor, cid);\n'
            '  return term_make(TAG_CTR, cid, loc);\n}\n'
            '#define term_ctr(cid, loc) p125_counted_ctr((cid), (loc))')
    replace('consuming-take', 'INLINE Loc ctr_take(Env e, Term t, u32 n, THR Term* out) {',
            'INLINE Loc ctr_take(Env e, Term t, u32 n, THR Term* out) {\n'
            '  P125_ADD(ctr_take_calls, 1); P125_ADD(ctr_take_fields, n);\n'
            '  P125_ADD(ctr_take_wrapped_calls, term_rfc(t) ? 1 : 0); P125_HIT(p125_take, term_aux(t));')
    replace('generic-extend', '  Env e = state->e; Loc at = heap_alloc(e, cls_fit(count + 1));',
            '  P125_ADD(extend_generic_calls, 1); P125_HIT(p125_extend, count);\n'
            '  Env e = state->e; Loc at = heap_alloc(e, cls_fit(count + 1));')
    old = '  Env e = state->e; Loc at = heap_alloc(e, cls_fit(N + 1)); \\\n'
    new = '  P125_ADD(extend_sized_calls, 1); P125_HIT(p125_extend, N); \\\n' \
          '  if (N == 1) P125_ADD(extend1_calls, 1); \\\n' + old
    replace('all-sized-extends', old, new)
    replace('normal-return-report', '  int code  = io_loop(H);\n  io_sync();\n  return code;',
            '  int code  = io_loop(H);\n  io_sync();\n  p125_dump(code);\n  return code;')
    support = '\n/* Phase125 count-only diagnostic. */\n' + (HERE / 'support.inc.c').read_text()
    derived = text + support
    inverse = derived[:-len(support)]
    for patch in reversed(patches):
        assert inverse.count(patch['new']) == 1, patch['label']
        inverse = inverse.replace(patch['new'], patch['old'])
    assert inverse == original, 'unrecorded source mutation'
    header = '''#ifndef P125_COUNTS_H
#define P125_COUNTS_H
#include <stdint.h>
#include <stddef.h>
'''
    header += '#define P125_SOURCE_SHA "' + PINS['runtime.c'] + '"\n'
    header += 'enum { ' + ', '.join('P125_C_' + name for name in COUNTERS) + ', P125_C_COUNT };\n'
    header += 'static uint64_t p125_invalid, p125_counts[P125_C_COUNT];\n'
    header += 'static uint64_t p125_ctor[65536], p125_take[65536], p125_extend[8];\n'
    header += 'static const char *const p125_names[] = {' + ','.join(json.dumps(n) for n in COUNTERS) + '};\n'
    header += '''static inline void p125_add(uint64_t *counter, uint64_t amount) {
  uint64_t before = *counter; *counter += amount;
  if (*counter < before) p125_invalid = 1;
}
#define P125_ADD(N,V) p125_add(&p125_counts[P125_C_##N], (V))
#define P125_HIT(A,V) do { uint64_t p125_i_ = (V); \\
  if (p125_i_ < sizeof(A)/sizeof((A)[0])) p125_add(&(A)[p125_i_], 1); \\
  else p125_invalid = 1; } while (0)
static void p125_dump(int status);
#endif
'''
    out.mkdir(parents=True)
    (out / 'runtime.c').write_text(derived)
    (out / 'p125-counts.h').write_text(header)
    for name in ['runtime.h', 'primitives.h']:
        (out / name).write_bytes((PARENT / name).read_bytes())
    manifest = dict(kind='phase125-diagnostic-count-runtime', diagnosticOnly=True,
        compiled=False, targetsRun=False, source=pin(out / 'runtime.c'), parent=pin(PARENT / 'runtime.c'),
        inputs=[pin(PARENT / 'report.json'), *[pin(PARENT / n) for n in PINS],
                pin(Path(__file__).resolve()), pin(HERE / 'support.inc.c'),
                pin(ROOT / 'selfhost/tools/performance/phase112/profile/counter-control.c')],
        outputs=[pin(out / n) for n in ['runtime.c', 'runtime.h', 'primitives.h', 'p125-counts.h']],
        exactInverseVerified=True, patches=patches, constructorSites=ctor_sites,
        counters=COUNTERS, scope='Whole p111_rt_main sequential CPU execution, including setup/wrapper/readback; no instrumented timing claims',
        requires=['exit status0', 'unchanged stdout', 'one P125_COUNTS record',
                  'record status0', 'overflowOrInvalid0', 'expected parent identity'])
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(json.dumps(dict(out=str(out), patches=len(patches), inverseVerified=True,
                          countersBytes=8 * (len(COUNTERS) + 1 + 65536 * 2 + 8))))


if __name__ == '__main__':
    main()
