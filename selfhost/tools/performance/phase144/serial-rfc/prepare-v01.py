#!/usr/bin/env python3
"""Prepare a pinned, opt-in single-Bend-mutator RFC experiment; execute nothing.

The qualified runtime and compiler object remain untouched. Both modes use the
same generated source; mode 0 is the atomic control. No atomic macro is changed.
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[5]
PARENT = ROOT / 'selfhost/build/phase128/runtime-borrow01'
OBJECT = ROOT / 'selfhost/build/phase111/p143-integrated-n2/program.o'
PIN = {
    'runtime.c': '6eb24c8d4a5d6358a9b8b4107a75af777a8dbdd06fe5fdce18d73b9f85f4824a',
    'runtime.h': '9b19b8d6ae1c8f07759041201c2692c20d9612393819e2bbc597deba44679d12',
    'primitives.h': 'ecbdfe62b875fc20e5805840b83c3779ed8fb8fb1de83c543ba1ce1217165d20',
}
OBJECT_SHA = '5cb69af0092ec33975302df0f01228ec58eca85549f0f98494abe0a9f5eb9777'
GCC = Path('/usr/bin/x86_64-linux-gnu-gcc-10')
GCC_SHA = '693abcb42e67fb871673f258a3644257ca69a209691ec4d8137a42442834bd19'

HELPERS = '''/* Phase144 experiment: one Bend heap mutator, not one host thread.
 * Mode 0 preserves atomic RFC operations. Mode 1 is valid only for the pinned
 * sequential ABI and fixed audited effect providers. IO workers operate on
 * detached host buffers; only the event loop packs values into the Bend heap.
 * Unknown runtime/provider changes require a new admission audit.
 */
#ifndef P144_SINGLE_MUTATOR_RFC
#define P144_SINGLE_MUTATOR_RFC 0
#endif
#if P144_SINGLE_MUTATOR_RFC != 0 && P144_SINGLE_MUTATOR_RFC != 1
#error "P144_SINGLE_MUTATOR_RFC must be 0 or 1"
#endif
#if P144_SINGLE_MUTATOR_RFC && (DEVICE || BEND_METAL || BEND_CUDA || BANGS)
#error "Phase144 serial RFC requires the sequential host-only runtime"
#endif

INLINE u32 p144_rfc_add(DEV u32* p, u32 k) {
#if P144_SINGLE_MUTATOR_RFC
  u32 old;
  memcpy(&old, p, sizeof old);
  u32 next = old + k;
  memcpy(p, &next, sizeof next);
  return old;
#else
  return a32_add(p, k);
#endif
}

INLINE u32 p144_rfc_sub(DEV u32* p, u32 k) {
#if P144_SINGLE_MUTATOR_RFC
  u32 old;
  memcpy(&old, p, sizeof old);
  u32 next = old - k;
  memcpy(p, &next, sizeof next);
  return old;
#else
  return a32_sub_rel(p, k);
#endif
}

'''


def identity(path):
    data = path.read_bytes()
    return {'file': str(path.resolve()), 'bytes': len(data),
            'sha256': hashlib.sha256(data).hexdigest()}


def replace_once(source, old, new):
    if source.count(old) != 1:
        raise ValueError(f'expected one exact source anchor: {old!r}')
    return source.replace(old, new, 1)


def transform(source):
    source = replace_once(source, 'INLINE void rfc_bump(Env e, Loc r, u32 k) {',
                          HELPERS + 'INLINE void rfc_bump(Env e, Loc r, u32 k) {')
    source = replace_once(source, 'u32 c = a32_add(a32_at(e.mem, r), k);',
                          'u32 c = p144_rfc_add(a32_at(e.mem, r), k);')
    source = replace_once(source, 'if ((a32_sub_rel(p, 1) & RFC_CNT) != 1) {',
                          'if ((p144_rfc_sub(p, 1) & RFC_CNT) != 1) {')
    source = replace_once(source, 'OUTLINE void pool_open(void) {',
                          '''OUTLINE void pool_open(void) {
#if P144_SINGLE_MUTATOR_RFC
  err_fail("phase144 serial RFC runtime refuses compute workers");
#endif''')
    return source


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out', required=True, type=Path, help='fresh preparation directory')
    args = ap.parse_args()
    out = args.out.resolve()
    inputs = []
    for path, digest in [(PARENT / name, sha) for name, sha in PIN.items()] + [
            (OBJECT, OBJECT_SHA), (GCC, GCC_SHA)]:
        item = identity(path)
        if item['sha256'] != digest:
            raise ValueError(f'input identity mismatch: {path}')
        inputs.append(item)
    source = transform((PARENT / 'runtime.c').read_text())
    # Fail before writing if these independently reviewed admission gates move.
    for gate in [
        'if (thr != 1 || gpu != 0) cli_fail("Phase111 ABI v1 requires --threads 1 --gpu off", NULL);',
        '"phase111: unsupported capabilities"',
        'cid != UINT32_MAX && io_eff_rows[cid].run != NULL',
        'a->item  = a->work.pack(e, &a->work);',
    ]:
        if source.count(gate) != 1:
            raise ValueError(f'admission anchor changed: {gate}')
    out.mkdir(parents=True, exist_ok=False)
    (out / 'runtime.c').write_text(source)
    for name in ('runtime.h', 'primitives.h'):
        shutil.copyfile(PARENT / name, out / name)
    commands = []
    for mode, name in ((0, 'atomic-control'), (1, 'serial-rfc')):
        obj = out / (name + '.o')
        binary = out / (name + '-compiler')
        commands.extend([
            {'label': name + '-compile', 'argv': [str(GCC), '-O2', '-std=gnu11',
             '-ffp-contract=off', '-DP144_SINGLE_MUTATOR_RFC=' + str(mode),
             '-c', str(out / 'runtime.c'), '-o', str(obj)]},
            {'label': name + '-link', 'argv': [str(GCC), '-no-pie', str(OBJECT),
             str(obj), '-pthread', '-lm', '-o', str(binary)]},
        ])
    manifest = {
        'kind': 'phase144-serial-rfc-preparation-v01', 'complete': True,
        'status': 'prepared-only-unbuilt-unqualified-unselected',
        'inputs': inputs + [identity(Path(__file__))],
        'outputs': [identity(out / n) for n in ('runtime.c', 'runtime.h', 'primitives.h')],
        'commands': commands,
        'scope': 'Two RFC update sites only; existing atomic loads, allocator, scheduler, IO synchronization and ABI admission unchanged.',
        'obligations': ['Exactly one Bend heap mutator; not a claim that the process has one host thread.',
                        'Mode1 fails closed if the compute worker pool is opened.',
                        'All fixed effect workers use detached host buffers; heap packing remains on event loop.',
                        'No arbitrary foreign callbacks; exact runtime/header identities are admission boundaries.',
                        'New modes require independent output, ownership, effect and refusal tests before use.'],
    }
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(json.dumps({'manifest': str(out / 'manifest.json'), 'status': manifest['status']}))


if __name__ == '__main__':
    main()
