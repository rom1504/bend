# Flat private results as an alternative physical convention

Date: 2026-10-05. Status: isolated proposal; no target execution or timing result.
Parent: checked values03. Installed compiler remains Phase47 array06.

The values03 pass demonstrably removes transient state construction from the
maintained RLE program: 15 array-literal evaluations become three, with unchanged
persistent list construction. Its first four-point timing screen is weak or
adverse. Zero source-level temporary arrays do not necessarily mean the fastest
JavaScript. The revised call convention introduces shared lexical result stores,
captures, clears and additional scalar copies; their contribution to the measured
cost has not been isolated.

This experiment retains the exact typed JW decomposition pass, shapes, bounds,
public entry exclusions, source guards and IR instructions. Only the emitter's
physical representation of `JWCallValues` and `JWReturnValues` changes:

- A multi-result function returns one fresh flat private array, containing two
  to four fields. It evaluates every field once and in order.
- A caller captures that vector once in a block-local `const $results`, then
  stores its own indexed fields into the existing destination slots.
- The machine fallback assigns the complete vector to `$value` before restoring
  the saved caller frame. The resumed caller follows the same capture rule.
- Same-component tail transfers retain the existing direct forwarding; there
  is no additional vector at each tail edge, only at a real multi-result return.
- The root closure has no lexical return registers, commit protocol, or clearing
  protocol. No new callback or public result adapter is introduced.

The vectors are fresh, private and never escape through the public entry. Every
projected index is an existing own field, so unpacking cannot invoke a prototype
getter. The vector cannot alias the destination register frame. Fields that
throw or call a host helper remain evaluated before the result is returned;
error-hook reentry gets an independent function-local result vector. Original
source dependencies and guards remain the authority for entering private code.

The expected tradeoff is one temporary vector versus several lexical scalar
stores. This may help V8, or merely restore allocation overhead. No JIT escape
analysis, write-barrier cost, or speed benefit is assumed. The unchanged 443-line
analysis still needs to earn its complexity; this alternative only reduces the
emitter from 487 to 459 physical lines, by 1,256 bytes.

The isolated derivation is
`selfhost/build/phase48/integration-values-vector01/prepare.py`. It takes frozen
`integration-values03`, copies all payloads unchanged except `worker-emit.bend`,
and retains a unified patch and hash receipt. Emitter SHA-256:
`fed5a70f12b6784b7deb7257ffae1185c30af8ece6ce02261a3107676578ce4a`.
No maintained source or scalar03 artifact is overwritten.

## Independent gates and selection

The original scalar03 controls remain unchanged. Explicit alternative controls
use the same fixture v4 and catalog:

- `aggregate-transport-vector-controls-v1.mjs` retains every value, exception,
  reentry, public ABI and persistent-alias check. Its state allocation witness
  requires removal of `n+2` array evaluations: the two initial state shells,
  plus one nested shell per transition. One flat result vector remains per step.
- `aggregate-rle-vector-counters-v1.mjs` requires the maintained RLE count to
  change **15 → 8**, retaining three persistent encoded-run pairs plus five
  temporary result vectors. Persistent `Con` / `Nil` counts must stay unchanged.
- The actual emitted-IR controller needs a separate vector-mode successor that
  retains pair/four-field recursion, native-budget exhaustion, saved frames,
  error/reentry and replay checks. Scalar-register marker/counter expectations
  must be replaced explicitly with vector-return/capture checks.

The shared marker is `/* private flat tuple transport */`; activation checks
also require the absence of `$workerValue` state. Presence of that marker alone
is not a performance or allocation witness. Timings use untouched modules.

Measure the same four corpus points and the already defined six diagnostic
scale points against array06, with pinned TypeScript in the same run. Distinguish
this vector candidate from scalar03 and compare fresh, balanced samples. The
unchanged full45 corpus remains the primary aggregate; additional diagnostic
points do not change its weights. If neither representation gives useful,
stable benefit, preserve both experiments and defer the pass rather than
expanding it without new evidence.
