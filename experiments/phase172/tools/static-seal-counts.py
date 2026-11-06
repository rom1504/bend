#!/usr/bin/env python3
"""Prepare a private baseline-only rfc_seal counter runtime; never run targets.

Run preparation under the caller's artifact guard. Compile/relink separately in
the root's single execution lane. No compiler or optimization semantics here.
"""
import argparse
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import fresh_output, pin, verify, require, write_json

RUNTIME_SHA = 'aa95d2c0426c05bcc4d34244dd8b22b79ebcaf6d30634569201961f60b57f333'
GCC_SHA = '693abcb42e67fb871673f258a3644257ca69a209691ec4d8137a42442834bd19'
BEFORE = '''INLINE Term rfc_seal(Env e, Term t) {
  if (term_tag(t) != TAG_CTR || term_rfc(t)) {
    return t;
  }
  return rfc_wrap(e, t, 1);
}'''
AFTER = r'''/* Phase172 baseline diagnostic only. No static-seal optimization.
 * Counts are per process and intentionally non-atomic: the pinned host has one
 * heap mutator. Raw counts are requests before rfc_wrap, not allocation success.
 * The destructor writes one diagnostic stderr line on normal process exit;
 * stdout and the original successful program operations are unchanged. */
#if DEVICE || BEND_METAL || BEND_CUDA || BANGS || !defined(P144_SINGLE_MUTATOR_RFC) || !P144_SINGLE_MUTATOR_RFC
#error "Phase172 seal counters require the pinned sequential host runtime"
#endif
static uint64_t p172_seal_calls;
static uint64_t p172_seal_identity;
static uint64_t p172_seal_static;
static uint64_t p172_seal_dynamic;

__attribute__((destructor)) static void p172_seal_counts_report(void) {
  fprintf(stderr, "P172_SEAL_COUNTS {\"kind\":\"phase172-rfc-seal-counts\","
    "\"totalCalls\":%llu,\"earlyIdentity\":%llu,"
    "\"rawStaticWrap\":%llu,\"rawDynamicWrap\":%llu}\n",
    (unsigned long long)p172_seal_calls,
    (unsigned long long)p172_seal_identity,
    (unsigned long long)p172_seal_static,
    (unsigned long long)p172_seal_dynamic);
}

INLINE Term rfc_seal(Env e, Term t) {
  p172_seal_calls += 1;
  if (term_tag(t) != TAG_CTR || term_rfc(t)) {
    p172_seal_identity += 1;
    return t;
  }
  if (term_loc(t) < HEAP_OFF) p172_seal_static += 1;
  else p172_seal_dynamic += 1;
  return rfc_wrap(e, t, 1);
}'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    source = ROOT / 'selfhost/src/runtime/qbe/runtime.c'
    source_pin = pin(source)
    require(source_pin['sha256'] == RUNTIME_SHA, 'Original runtime identity changed')
    original = source.read_text()
    require(original.count(BEFORE) == 1, 'Expected one exact original seal body')
    require('p172_seal_calls' not in original and 'P172_STATIC_SEAL' not in original,
            'Expected unmodified original runtime')
    candidate = original.replace(BEFORE, AFTER, 1)
    require(candidate.count(AFTER) == 1 and candidate.replace(AFTER, BEFORE, 1) == original,
            'Counter edit inverse differs')
    manifest = ROOT / 'selfhost/manifests/assets-native.json'
    assets = json.loads(manifest.read_text())['assets']
    compiler = pin(ROOT / assets['linker']['file'])
    require(compiler['sha256'] == GCC_SHA == assets['linker']['sha256'], 'Pinned GCC differs')
    reference = pin(ROOT / assets['qbe-runtime']['file'])
    require(reference['sha256'] == assets['qbe-runtime']['sha256'], 'Reference object differs')
    out = fresh_output(args.out, ROOT)
    (out / 'runtime.c').write_text(candidate)
    headers = []
    for name in ('runtime.h', 'primitives.h'):
        path = source.parent / name
        (out / name).write_bytes(path.read_bytes())
        headers.append(dict(original=pin(path), snapshot=pin(out / name)))
    inputs = [pin(__file__), pin(ROOT / 'selfhost/tools/build/common.py'), pin(manifest),
              source_pin, compiler, reference, *[row['original'] for row in headers]]
    for item in inputs:
        verify(item)
    plan = dict(kind='phase172-static-seal-counter-plan', version=1, complete=True,
        preparationOnly=True, targetsRun=False, productionChanged=False, inverseExact=True,
        inputs=inputs, source=pin(out / 'runtime.c'),
        headers=[row['snapshot'] for row in headers], compiler=compiler,
        referenceRuntime=reference, edit=dict(before=BEFORE, after=AFTER),
        flags=['-O2', '-std=gnu11', '-ffp-contract=off', '-DP144_SINGLE_MUTATOR_RFC=1'],
        stderrPrefix='P172_SEAL_COUNTS ',
        expectedIdentity='totalCalls == earlyIdentity + rawStaticWrap + rawDynamicWrap',
        counterScope='Baseline rfc_seal calls only; raw categories count attempted rfc_wrap requests. Direct rfc_wrap calls outside rfc_seal are not counted.',
        executionRequirements=['Only valid successful independently checked programs',
          'Exactly one diagnostic stderr line and the complete unchanged stdout oracle',
          'Authenticate source, headers, compiler and unchanged program object before relink',
          'Use original runtime for clean timings; never use counter timings as performance evidence'],
        scope='Diagnostic opportunity census only; no static optimization or generated-code change. No machine construction or generated program execution performed.')
    write_json(out / 'plan.json', plan)
    print(json.dumps(dict(plan=str(out / 'plan.json'), source=plan['source'], targetsRun=False)))


if __name__ == '__main__':
    main()
