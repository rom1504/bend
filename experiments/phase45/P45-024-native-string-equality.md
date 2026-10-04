# P45-024: admit exact native String equality

Status: **retained, unselected prototype**. Candidate24 passes its checked build,
eight maintained suites, independent native-equality controls and five unchanged
canaries. A clean short screen observes 1.17059× Map/Set improvement with
substantial drift and 56.5% larger emitted code. The combined successor25 later
observes 1.37766× over installed23 in a longer confirmation, still with drift;
neither image receives full qualification or selection. Worker23 remains the
installed usable release. See the
[final report](../../implementation/phase45/native-string-equality.md) for the
separate protocols, exact receipts, code-size cost and compiler-cost limitation.

The following proposal and serial-queue plan record the scope fixed before
execution; their earlier no-execution statements describe that planning stage.

## Hypothesis and smallest change

The [remaining coverage inspection](../../design/phase45/remaining-general-coverage.md)
found an exact proof gap: `String.eq` is an intrinsic, but the private residual
String whitelist admits only append. Some remaining Map/Set graphs therefore
fail this gate. Admitting the exact existing native operation may close those
graphs; it does not prove that no later gate will refuse them.

The [patch](../../selfhost/tools/performance/phase45/string-equality-native-frozen23-v1.patch)
changes only `src/back/js/jpure.bend`. The shared String-native signature check
accepts `String.append` or `String.eq`, retaining `Def`, native provenance,
arity two, zero type parameters and non-Foreign body requirements. Both binders
must have quantity one and the canonical String type. Append still requires a
String result; equality requires the canonical primitive Bool result.

`JWNative` is unchanged: it emits `callOwned(get(G,name),[args])`. The existing
native boundary permits two String values and a Bool result without exposing
private tagged layouts. The completed dependency graph still contributes the
exact `String.eq` descriptor to `localGuard`; source, primitive and complete host
and String guards remain. Arguments are lowered in their original order. No
source-program selector, new backend path or emitted-text recognition is added.

The runtime operation is deliberately unchanged. It checks well-formed strings
and otherwise compares checked code points. Lone-surrogate errors and mismatch
short-circuiting are observable; replacing it with JavaScript `===` is incorrect.

The Number-Nat pass's separate native whitelist is **unchanged**. A graph that
contains equality conservatively retains BigInt Nat representation. This is
safe but can limit gains or regress a previously selected alternative; measure
it explicitly before considering a separate representation-proof extension.

## Independent falsifiers

The [renamed fixture](../../selfhost/tools/performance/phase45/fixtures/string-equality-native-v1.bend)
uses recursive String transport and append followed by equality, returning a
scalar Bool. A separate contextual root constructs `Chr{code}` and compares its
one-character String. That error path is a real **Char-construction** range
error before equality, not a malformed String entering a private worker.
Public String arguments remain outside contextual admission.

The [controller](../../selfhost/tools/performance/phase45/string-equality-native-controls-v1.mjs)
and [catalog](../../selfhost/tools/performance/phase45/string-equality-native-catalog-v1.json)
are proposals, not executed evidence. They require checked source/API/runtime
receipts and pin/recheck all inputs. Planned checks are:

- Fourteen recursive scalar cases and 121 independent valid String pairs across
  baseline23, candidate and pinned TypeScript, including empty, non-BMP, prefix,
  normalization-distinct and NUL strings.
- Six explicit malformed public-String cases against the exact predecessor:
  high/low surrogate errors, left-to-right errors and mismatch/empty
  short-circuiting. These do not claim private malformed-string admission.
- Complete-root AST admission/refusal checks and untimed derived counters for
  both newly admitted roots, a genuine private source error and clean replay.
- Eleven native `G`, descriptor, environment and `.call` mutation controls;
  eight String host-method/getter controls, preserving receiver and call order.
- Global Error-hook observation and reentry compared exactly with baseline.
  Error is intentionally supported, not guarded out: `bad()` suspends the proof,
  the failing private scalar entry is counted, and a reentrant bench can enter.

Run only after worker23 qualification/promotion, using three fresh checked
emissions of this exact catalog, then:

```sh
node selfhost/tools/performance/phase45/string-equality-native-controls-v1.mjs \
  BASELINE23_MODULE CANDIDATE_MODULE TYPESCRIPT_MODULE NEW_OUTPUT_DIRECTORY
```

Require all named gates before a short paired Map/Set and independent-source
screen. Preserve any build, fixture, controller or runtime failure separately.
Only broader qualification can justify selection; this note reserves no claim
that a small admission patch improves all programs.

## Preserved proposal identity

Patch SHA-256: `576d0bbae686a64c6955f1a0d39b180a676be59c3bc81494a205f7edb89e4bd2`.
The exact frozen before/after files and receipt are in
`selfhost/build/phase45/string-equality24-v1/`; the tracked patch above is the
reproducible source change. `git apply --check --directory=selfhost` and Node
syntax checking passed. No compiler or generated program was executed by the
proposal author or reviewer.

## Frozen minimal execution sequence

The root may execute the isolated queue **after worker23 installation and smoke**:

```sh
python3 selfhost/build/phase45/string-equality24-v2/serial-queue.py \
  --execute-after-worker23-smoke
```

The preserved v1 queue is superseded by v2. V2 verifies the exact successful
worker23 smoke launcher and all 42 checks, bound to the current release.
Its adjacent `test-sequence.json` holds exact argument vectors;
`queue-inputs.json` pins the helper, source, catalog, patch, configuration and
existing tools before execution. It requires the installed worker23 API/runtime,
clones `source-worker23` to a fresh `source-worker24`, applies only the proposal,
and verifies that `jpure.bend` is the sole changed file. Production source and
installation are never changed by this queue. Any failed command stops it and
retains its job receipt; retries require fresh paths and a successor queue.

Order: checked B1 build; eight maintained suites; three fresh checked emissions
of the independent fixture; its untimed controller; five fresh corpus source
emissions (six modules including the row observer) for seven points; bind the saved exact worker23 and TypeScript modules;
static source/entry comparison; five mandatory canaries; Map/Set and Unicode screen.
The canaries are `local-pair`, `local-fold`, `scalar-region-0`,
`scalar-region-8192`, and `complete-generic-row32`. Each of the two timing batches
has a 60-second budget, not a duration promise; the runner records any
`budgetOverrunSeconds`. Compilation is excluded.
The first invocation stops after the five canaries. The root reviews those
timings before invoking the same helper with `--run-focus-after-canary-review`;
no unexplained material-regression decision is automated.

Static comparison requires the four unaffected source modules and the complete
row observer to remain byte-identical. Map/Set must gain an actual contextual
entry before timing begins. No fresh entry means the predicted corpus mechanism
did not land; stop rather than expanding validation. Changes to unrelated code
also stop the queue for diagnosis. Broader qualification remains a separate
parent decision; passing this queue does not install candidate24.

The expected upside is narrow. Only `test-map-set-ops` among the 23 timed source
fixtures explicitly calls `String.eq` (two sites); pinned Base contains its
definition but no callers. `chk_order` and `chk_set` are plausible newly closed
graphs: this source's `Str.join` is first-order, unlike the morning example's
function-returning helpers. Complete `main.out` admission still depends on all
other branches, including presently refused `chk_del`; this inspection does not
prove that graph. Equality's safe BigInt-Nat fallback can offset dispatch gains.
The Unicode benchmark uses its own structural equality and split/join, so it is
a preservation check rather than a predicted winner. This is a bounded native
coverage experiment, not a broad performance or parity proposal.
