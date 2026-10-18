#!/usr/bin/env python3
"""Extract the descriptor-bound Phase111 CPU runtime from exact Phase108 v3 bytes.

Data/source preparation only: this script never invokes a C compiler or target.
"""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
BASE = dict(bytes=86187, sha256='bffb4258ac362a338b18bb7a6ece1c816a46e6f3112a3cb594d65ae79cdde0dc')

def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.resolve()), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())

def verify(row):
    path = Path(row['file'])
    if pin(path) != row: raise ValueError('changed input: ' + str(path))
    return path

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--runtime', type=Path, default=ROOT / 'selfhost/build/phase108/portable-source04/runtime.c')
    p.add_argument('--effects', type=Path, default=HERE / 'effects/prepared01')
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase111'):
        raise ValueError('fresh Phase111 output directory required')
    identity = pin(a.runtime)
    if {k: identity[k] for k in BASE} != BASE: raise ValueError('requires exact portable v3 runtime')
    effects_manifest = a.effects / 'manifest.json'
    effects = json.loads(effects_manifest.read_text())
    if effects['kind'] != 'phase111-cached-effects-source' or not effects['complete']:
        raise ValueError('complete cached effect source required')
    effect_outputs = [effects['providers'], effects['catalogue']]
    for row in effects['inputs'] + effect_outputs: verify(row)
    paths = [HERE / name for name in ['runtime.h', 'primitives.h', 'tables.inc.c', 'dispatch.inc.c', 'core.inc.c', 'primitives.inc.c', 'catalogue.json']]
    inputs = [identity, pin(Path(__file__)), pin(effects_manifest), *effects['inputs'], *effect_outputs, *map(pin, paths)]
    source = a.runtime.read_text(); edits = []
    def replace(name, old, new):
        nonlocal source
        if not old or source.count(old) != 1: raise ValueError('non-unique exact source boundary: ' + name)
        source = source.replace(old, new, 1)
        edits.append(dict(name=name, oldBytes=len(old.encode()), newBytes=len(new.encode()),
            oldSha256=hashlib.sha256(old.encode()).hexdigest(), newSha256=hashlib.sha256(new.encode()).hexdigest()))
    replace('public-env-alias', 'typedef struct {\n  Corpus   mem;\n  DEV u64* alc;\n} Env;', 'typedef P111Env Env;')
    state = 'typedef struct {\n  Env e;\n  Stk sp;\n  u32 seq;\n  u32 rn;\n  u32 next;\n  Term regs[WL_WIDTH];\n} WlState;'
    replace('public-state-alias', state, 'typedef P111State WlState;')
    marker = '// Tables\n// ======'
    replace('descriptor-tables', marker, marker + '\n\n' + (HERE / 'tables.inc.c').read_text())
    replace('function-arity', '#define fid_arity(x) ((u32)FID_ARITY_T[x])', '#define fid_arity(x) p111_fid_arity(x)')
    replace('function-bang', '#define fid_bangs(x) ((bool)(FID_FLAG_T[x] & 1))', '#define fid_bangs(x) ((bool)(p111_fid_flags(x) & 1))')
    replace('function-fork', '#define fid_nofk(x) ((bool)(FID_FLAG_T[x] & 2))', '#define fid_nofk(x) ((bool)(p111_fid_flags(x) & 2))')
    replace('function-results', '#define fid_resw(x) ((u32)FID_RESW_T[x])', '#define fid_resw(x) p111_fid_results(x)')
    start = source.index('// A host self-jump is a tail call:')
    end = source.index('// Segments\n// ========', start)
    replace('descriptor-dispatch', source[start:end], (HERE / 'dispatch.inc.c').read_text() + '\n\n')
    replace('closure-apply-width-guard', '    Fid f    = (Fid)term_aux(fun);\n    u32 war  = fid_arity(f) - 1;',
      '    Fid f    = (Fid)term_aux(fun);\n    u32 p111_arity = fid_arity(f);\n    if (term_tag(fun) != TAG_CLO || f > FID_IO_EMIT || p111_arity == 0 || p111_arity > P111_REG_CAP) {\n      err_post(e.mem, ERR_FIDS); return 0;\n    }\n    u32 war = p111_arity - 1;')
    replace('task-enter-width-guard', '    u32 war = fid_arity(f);\n    WL_FRAME(t)',
      '    u32 war = fid_arity(f);\n    if (f > BEND_CLO_APPLY || war > P111_REG_CAP || fid_resw(f) > war) {\n      err_post(e.mem, ERR_FIDS); return 0;\n    }\n    WL_FRAME(t)')
    replace('exit-result-width-guard', '    u32  n = rn;\n    Term rv[WL_RESW];',
      '    u32  n = rn;\n    if (n > P111_RESULT_CAP) { err_post(e.mem, ERR_FIDS); return 0; }\n    Term rv[WL_RESW];')
    replace('continuation-resume-width-guard', '      u32 wn = fid_arity(wf);\n      WL_FRAME(cont)',
      '      u32 wn = fid_arity(wf);\n      if (wn > P111_REG_CAP || n > wn) { err_post(e.mem, ERR_FIDS); return 0; }\n      WL_FRAME(cont)')
    replace('compile-pure-readback', '// Show\n// ====\n\n#if MAIN_PURE\n', '// Show\n// ====\n\n#if 1\n')
    replace('descriptor-main-purity', "#if MAIN_PURE\n  show_val(e, 0, H + H_ROOT_WORD, 0);\n  putchar('\\n');\n  return 0;\n#endif", "if (MAIN_PURE) {\n    show_val(e, 0, H + H_ROOT_WORD, 0);\n    putchar('\\n');\n    return 0;\n  }")
    replace('empty-static-image', '  memcpy(H + STAT_OFF, STAT_IMG, STAT_LEN * sizeof(u64));', '  if (STAT_LEN) memcpy(H + STAT_OFF, STAT_IMG, STAT_LEN * sizeof(u64));')
    marker = '// Requests\n// ========'
    addition = '\n\n'.join((path.read_text() for path in [a.effects / 'providers.inc.c', HERE / 'core.inc.c', HERE / 'primitives.inc.c']))
    replace('scalar-abi-and-cached-effects', marker, marker + '\n\n' + addition)
    replace('descriptor-main-entry', 'int main(int argc, char** argv) {', 'int p111_rt_main(int argc, char** argv, const P111Program *program) {\n  p111_bind(program);')
    replace('one-cpu-default', '  long thr = 0;\n  int  gpu = -1;', '  long thr = 1;\n  int  gpu = 0;')
    replace('cpu-capability-check', '  bool dev = gpu != 0 && BANGS != 0 && gpu_probe();', '  if (thr != 1 || gpu != 0) cli_fail("Phase111 ABI v1 requires --threads 1 --gpu off", NULL);\n  bool dev = false;')
    prefix = '#ifndef _GNU_SOURCE\n#define _GNU_SOURCE\n#endif\n#define WL_PORTABLE 1\n#define BEND_CPROC 0\n#define BEND_METAL 0\n#define BEND_CUDA 0\n#include "runtime.h"\n'
    source = prefix + source + '\n_Static_assert(STAT_OFF == UINT64_C(51413504), "static image base ABI");\n'
    if 'int main(' in source or '__attribute__((constructor))' in source:
        raise ValueError('unexpected generated main or startup effect constructor')
    out.mkdir(parents=True)
    for name in ['runtime.h', 'primitives.h']:
        (out / name).write_bytes((HERE / name).read_bytes())
    (out / 'runtime.c').write_text(source)
    outputs = [pin(out / name) for name in ['runtime.c', 'runtime.h', 'primitives.h']]
    record = dict(kind='phase111-descriptor-runtime-source', version=1, complete=True, targetsRun=False,
        abiVersion=11101, stateBytes=2088, descriptorBytes=192, registerCapacity=256, resultCapacity=256,
        staticWordOffset=51413504, inputs=inputs, outputs=outputs, edits=edits,
        genericSegmentABI='uint64_t segment(P111State*)',
        scope='One synchronous CPU program/context; checked sequential lowering. Retained allocator/refcounts/closures/tasks/effects/show, no per-program C translation unit.',
        buildCommand=['gcc','-O2','-std=gnu11','-ffp-contract=off','-c',str(out/'runtime.c'),'-o',str(out/'runtime.o')],
        linkExample=['gcc','-no-pie','PROGRAM_QBE_OBJECT',str(out/'runtime.o'),'-pthread','-lm','-o','PROGRAM'])
    for row in inputs: verify(row)
    (out / 'manifest.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, manifest=str(out / 'manifest.json'))))

if __name__ == '__main__': main()
