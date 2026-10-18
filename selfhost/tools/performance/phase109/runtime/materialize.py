#!/usr/bin/env python3
"""Extract authenticated production ownership core; append an explicit small ABI.

No generated C bodies are read, parsed or translated. No target tools are run.
"""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
BASE = ROOT / 'selfhost/build/phase90/runtime-accessor-transport02/runtime.c'
BASE_SHA = '9e1c59078878be94052cb4d2d63a713e19e29b41ed3f94b034f2175a50efd0a9'


def pin(path):
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def between(text, start, end):
    if text.count(start) != 1 or text.count(end) != 1:
        raise ValueError('runtime extraction boundary is not unique')
    a, b = text.index(start), text.index(end)
    if a >= b:
        raise ValueError('runtime extraction boundaries reversed')
    return text[a:b]


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', required=True, type=Path)
    p.add_argument('--production-workers', action='store_true',
                   help='Append exact frozen production C workers as a matched reference')
    args = p.parse_args()
    out = args.out.resolve()
    if not out.is_relative_to(ROOT / 'selfhost/build/phase109') or out.exists():
        raise ValueError('output must be fresh under selfhost/build/phase109')
    identity = pin(BASE)
    if identity['bytes'] != 83683 or identity['sha256'] != BASE_SHA:
        raise ValueError('selected production runtime identity differs')
    text = BASE.read_text()
    core = text[:text.index('// Blk\n// ===\n')]
    # Same alignment meaning as the Phase108 BEND_CPROC adaptation, now shared
    # by every comparison profile so frontend syntax is not an ablation.
    align_old = 'static u64    ALC[CUBE_T + 1][3 * ALC_WORDS] __attribute__((aligned(128)));'
    align_new = '_Alignas(128) static u64 ALC[CUBE_T + 1][3 * ALC_WORDS];'
    if core.count(align_old) != 1:
        raise ValueError('production allocator alignment declaration differs')
    core = core.replace(align_old, align_new, 1)
    table = '''/* Fixed Phase109 ABI v1 descriptor; not a general program table. */
#define WL_RESW 1
#define STAT_LEN 128
#define CID_WCON 65535
static const unsigned char CID_ARITY_T[4] = {0, 2, 0, 2};
static const unsigned char CID_HOT_T[4] = {0, 1, 0, 1};
static const unsigned char FID_ARITY_T[1] = {1};
'''
    # Constants refer to these macros only at their later expansion sites.
    core = core.replace('// Tables\n// ======\n', '// Tables\n// ======\n\n' + table, 1)
    pool = between(text, 'static void* pool_try(void* at, u64 bytes) {',
                   'static void* pool_mmap(u64 bytes) {')
    corpus = between(text, 'static u64 corpus_size;',
                     'static Corpus corpus_setup(bool gpu, long threads, u64 bytes) {')
    adapter = HERE / 'adapter.inc.c'
    result = core + '\n' + pool + '\n' + corpus + '\n' + adapter.read_text()
    extra_inputs = []
    if args.production_workers:
        workers = HERE.parent / 'controls/production-workers.c'
        workers_manifest = HERE.parent / 'controls/production-workers.json'
        facts = json.loads(workers_manifest.read_text())
        if pin(workers)['sha256'] != facts['extracted']['sha256']:
            raise ValueError('frozen production worker identity differs')
        result += '''
/* Exact production bodies; only this fixed descriptor's numeric IDs differ. */
#define NF_INLINE static inline
#define CID_NIL NX_RT_NIL
#define CID_CON NX_RT_CON
#define CID_SNIL NX_RT_SNIL
#define CID_SCON NX_RT_SCON
#define NATIVE_COLD_CTORS 1
#define NATIVE_HOT_CID_CON 1
#define NATIVE_HOT_CID_SCON 1
'''
        result += workers.read_text()
        result += '''
uint64_t nx_list_reverse(NxRt *ctx, uint64_t xs, uint64_t acc) {
  Term out[1];
  Term ok = NF_FID_110_116_95_114_101_118_101_114_115_101_(nx_env(ctx), true, out, xs, acc);
  nx_require(ok == 1, "production List worker failed");
  return out[0];
}
uint64_t nx_string_reverse(NxRt *ctx, uint64_t xs, uint64_t acc) {
  Term out[1];
  Term ok = NF_FID_83_116_114_105_110_103_46_114_101_118_101_114_115_101_46_103_111_(nx_env(ctx), true, out, xs, acc);
  nx_require(ok == 1, "production String worker failed");
  return out[0];
}
'''
        extra_inputs = [pin(workers), pin(workers_manifest)]
    out.mkdir(parents=True)
    source = out / 'runtime.c'
    source.write_text(result)
    (out / 'abi.h').write_bytes((HERE / 'abi.h').read_bytes())
    record = dict(kind='phase109-production-runtime-core', version=1, complete=True,
                  targetsRun=False, base=identity,
                  inputs=[pin(Path(__file__).resolve()), pin(adapter), pin(HERE / 'abi.h')] + extra_inputs,
                  productionWorkers=args.production_workers,
                  adaptations=[dict(name='C11 allocator alignment',
                    old=align_old, new=align_new,
                    semantics='Same 128-byte alignment; shared by GCC, Clang and cproc comparison profiles.',
                    precedent='Phase108 runtime-recipes.json v1 allocator alignment adaptation')],
                  outputs=[pin(source), pin(out / 'abi.h')],
                  descriptor=dict(version=1, constructors=[
                    dict(id=0, name='Nil', fields=0), dict(id=1, name='Con', fields=2),
                    dict(id=2, name='SNil', fields=0), dict(id=3, name='SCon', fields=2)]),
                  trustedWorkerAbi=dict(version=1,
                    requiredAdmission='Checked fixed-table input graphs and verified structured ownership IR',
                    imports=['fast_id', 'fast_keep', 'fast_sink', 'fast_zero',
                             'fast_build2', 'fast_take2', 'fast_field', 'rebuild2'],
                    publicChecksUnchanged=True,
                    reusableSpare='Only ctr_take results >= HEAP_OFF; zero/shared and immortal static cases allocate'),
                  scope='One CPU context; actual allocator, reference counts, ownership and corpus growth; no scheduler or device execution.')
    (out / 'manifest.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(record))


if __name__ == '__main__':
    main()
