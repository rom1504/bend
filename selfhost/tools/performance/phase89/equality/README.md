# False-before-String equality falsifier

**Rejected at the first source gate.** Root ran the retained
[`equality01` acquisition](../../../../build/phase89/equality01/report.json).
The parser rejects line 9, `match a b`, because `a` is matched after a match on
the later binder `same`: "'a' can't be matched in this position". The guarded
job returned 1 after 0.921 s with 176,095,232-byte peak RSS. No C or JS was
emitted; there is no correctness, code-shape or speed result. Stop this candidate.
The source, derivation and original command recipe below are retained unchanged;
the later commands were not run and must not be treated as successful gates.

`controls.bend` differs
from Phase88 `strings/controls-v5.bend` only in the equality worker body. The
strings remain first in the recursive argument tuple, but the carried Bool is
matched before either String. A False result releases the two remaining roots
without destructuring one more pair of SCon nodes. Equal-prefix traversal still
consumes every visited shared node; this is **not borrowed-root lowering** and
does not predict removal of the profile's 30.42% equality ownership samples.

Phase88 V3 put Bool first in the arguments and failed decreasing-tuple checking.
This candidate preserves V5's `(a,b,same)` argument order. The first gate now
shows that argument order also constrains nested match order: preserving the
decreasing tuple alone does not make this source admissible.
Ordering, the 38-string corpus, all 1,444 pair checks, copied/shared inputs and
post-comparison input observations are unchanged. `controls.json` retains the
independent codepoint oracle; `derivation.json` binds old/new bytes. The candidate
SHA is `27e4622f6da61250760b3c97fa34234be2dad85ab74355ecb350de5826977e60`.

Root runs these serially from the repository, with fresh output directories.
Stop on failed source checking; do not patch the checker or relax ownership.

```sh
python3 -B selfhost/tools/performance/phase86/guard.py \
  --out selfhost/build/phase89/equality01-acquire-guard --seconds 40 -- \
  /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  selfhost/tools/performance/phase88/component.mjs \
  selfhost/tools/performance/phase89/equality/controls.bend \
  selfhost/build/phase89/equality01
python3 -B selfhost/tools/performance/phase86/guard.py \
  --out selfhost/build/phase89/equality01-js-guard --seconds 20 -- \
  /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  selfhost/build/phase89/equality01/program.cjs
python3 -B selfhost/tools/performance/phase86/guard.py \
  --out selfhost/build/phase89/equality01-build-guard --seconds 60 -- \
  /home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang \
  -isystem /home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/include/clang \
  -O2 selfhost/build/phase89/equality01/program.c \
  -o selfhost/build/phase89/equality01/program -lm -pthread
python3 -B selfhost/tools/performance/phase86/guard.py \
  --out selfhost/build/phase89/equality01-native-guard --seconds 20 -- \
  selfhost/build/phase89/equality01/program --threads 1 --gpu off
python3 -B selfhost/tools/performance/phase88/strings/compare-output.py \
  selfhost/tools/performance/phase89/equality/controls.json \
  selfhost/build/phase89/equality01-js-guard/stdout.log \
  selfhost/build/phase89/equality01-native-guard/stdout.log \
  selfhost/build/phase89/equality01-comparison.json
```

Expected full stdout is 85,349 bytes, SHA256
`06c0fd2c626a3d5d62cfc010ec05e5e7b38e16e3eea7ee5dc15f044c4f1a5df6`,
the independently qualified V5 result. Inspect the emitted equality worker's
False path before a performance test: it should sink its remaining String roots
without `ctr_take` on them. If the optimizer already produces identical code,
there is no mechanism to justify a full compiler build. Tiny correctness clocks
are not compiler performance measurements; any later scaling benchmark must
explicitly retain Strings to test shared input and separate mismatch position
from length.
