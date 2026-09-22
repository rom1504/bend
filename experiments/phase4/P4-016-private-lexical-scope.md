# P4-016: preserve lexical scope when specializing private workers

- Owner: root / direct-calls agent; independent review: compact-index agent.
- Correctness: **counterexample found** in full-source compilation.
- Measurement: the failed 602-second run is invalid as a successful-compile timing.
- Decision: lexical-scope fix accepted after independent review; full-source rerun pending.
- Evidence: [failed launch](../../implementation/phase4/private-scope-evidence/failed-full-source-launch.json),
  [measurement](../../implementation/phase4/private-scope-evidence/failed-full-source-measurement.json),
  [consumed transform](../../implementation/phase4/private-scope-evidence/failed-calls-transform.mjs).

## Claim and counterexample

The private call transform must only hoist a generated function when its lexical
bindings remain available. The full-source canonical private image checks the
source, then reports `Error: F is not defined` in compilation. The public source
has already passed the byte-identical self-hosting proof.

The emitter places split functions inside blocks containing a local `F` helper
table. The private transform selected ordinary `G` functions whose bodies refer to
that table, then placed positional workers at module scope. Token inspection
identifies real captures in `nb_fork_close` and `j_escape_char_on`. An initial
text search also flagged `j_l_walk` and `j_expr`, but their F references are
quoted emitted-code text, not captured identifiers. The exact
failing image is `75ebe9e0b3f1f103250621c77c1e455160f83f1479740f8f440c54a6d4dfa598`.

## Reduced source counterexample

The [four-line escaped-string program](../../selfhost/tests/fixtures/private-string-escapes.bend)
reproduces the checked compile error in seconds with the frozen bad image. An
ASCII-only string succeeds. Earlier reductions without a return type or Base
import failed earlier and are retained as setup attempts, not reproductions.

## Next discriminating test

Reduce to a small captured-helper example and actual emitted workers, then
conservatively exclude scoped definitions or preserve their exact scope. Keep
the original generic path for excluded workers. Test lexical capture and nested
scopes before rebuilding a new private image. Do not repeat a ten-minute compile
to debug a failure reproducible in seconds. A successful fix needs exact
full-source output and broad final-image observations before promotion.

## Preservation

The [archive manifest](../../implementation/phase4/private-scope-evidence/manifest.json)
retains the original failure, image manifest, transform and resource result.
Earlier small-program and frontend observations remain valid for their tested
inputs; they did not exercise this emission branch and do not override this
counterexample. Existing images are immutable and remain available for replay.

## Fix checkpoint

The scanner now proves module-level scope for hoisted definitions and leaves
block-scoped definitions on the original path. Unknown syntax and duplicate
emitted globals are refused. All 25 package tests, 14 actual split-worker controls
and the escaped-string source pass. The latter emits exactly the public-H bytes.
See the [fix report](../../implementation/phase4/private-scope-fix.md) and
[independent review](../../implementation/phase4/private-scope-review.md).
A new immutable image `61e7d94c…` is running the full-source gate; the old failed
image and its reports remain unchanged.
