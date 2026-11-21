# Neutral equality observer: ready bounded falsifier

This candidate implements the previously identified, unselected Phase193
neutral-observer opportunity at the compiler-source level. It removes the
per-character Bool recurrence state from `p88_string_eq_go`, replacing it with a
two-cursor worker. Character mismatch returns immediately rather than entering
the next iteration with False. The historical entry retains all three arguments
and its complete contract, including False on empty/empty with same=False.
`p88_string_eq` and its root lifetime adapter remain byte-identical. No unsafe
annotation is added. This is an exact compiler helper rewrite, not a general
optimizer or a new native String layout.

Phase201 slice02 actual self-compiler samples: equality154/2321, index_hash114/2321,
String.order113/2321. The capture has774 overruns, zero drops; these are approximate
physical shares, not removable-time guarantees. The QBE companion has111/1902,
83/1902 and46/1902 respectively, with634 overruns. profile01 is truncated before
its PCS section and cannot support attribution. Source02 already fuses ELF
symbol name/hash/update; that optimization is not repeated here. Global hash
memoization/interning would require a much broader immutable-name identity and
heap-lifetime contract, so none is claimed.

The semantic identity is E(a,b,s)=s AND (a=b), proved by induction on the shorter
String. Existing Char.is_eq is retained; prefix/empty/Unicode behavior is exact.
Dropping untouched tails on mismatch remains ordinary checked ownership. This
proof concerns typed values; no claim authorizes weakening native malformed
representation checks. Actual borrowed admission and root cleanup must be
verified in the generated closure before relying on timing.

Ready commands, from the repository root (fresh directories; root owns lane):

```
python3 -B research/phase202/names/prepare.py \
  --source selfhost/build/phase201/source02/compiler.bend --out FRESH/compiler.bend
python3 -B selfhost/tests/phase190/prepare-api.py \
  --parent-source FRESH/compiler.bend --assets selfhost/build/phase194/assets.json \
  --out FRESH_API_SOURCE --export p88_string_eq_go --export p202n_original \
  --export p202n_eq --export x187_prepared
```

Acquire by the existing checked hosted route, then run:

```
selfhost/.assets/bin/bun research/phase202/names/controls.mjs \
  --api CHECKED_API/report.json --out FRESH_CONTROLS
```

Controls contain18 distinct strings, all ordered pairs, both accumulator states,
and an independent Unicode exact-equality oracle:1620 observations across the
original/candidate/neutral entries. They do not establish native ownership.
Before any full-image build, emit a tiny equal/mismatch/repeated-prefix helper
fixture through the ordinary direct route. Require the neutral worker's actual
loop to have no carried Bool or recursive mismatch iteration, and inspect that
borrowed-reader admission survives. If admission fails, stop: the consuming
fallback can overwhelm the proposed saving. Root lifetime and checked static,
shared/RFC and empty strings need hardware controls. A complete native compiler
request must retain exact generated-object bytes before accepting performance.

No compiler, target, test or benchmark was run. The likely ceiling from equality
alone is modest (at most its physical share plus related runtime work). This is
a cheap falsifier, not evidence for a large cold-build gain; additional changes
to ordering or hash traversal are deliberately not mixed into attribution.
