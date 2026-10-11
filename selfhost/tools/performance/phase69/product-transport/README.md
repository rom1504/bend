# Constructor-proven product loops

[Hypothesis](../../../../../experiments/phase69/P69-004-product-transport.md).
This lane prepares saved C and a bounded compiler design; only the root executes
the compiler, Clang or native targets. There is no production source patch yet.

## Exact diagnostic

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase69/product-transport/prepare.py \
  --input selfhost/build/phase68/native-facts23-lexer/lexer-selfhost/program.c \
  --out selfhost/build/phase69/product-transport23-prep01

taskset -c 0 python3 -B selfhost/tools/performance/phase69/product-transport/prepare.py \
  --input selfhost/build/phase68/parity-survey23-static-prep01/static-and-bangs-zero.c \
  --out selfhost/build/phase69/product-transport23-combined-prep01
```

Both preparation receipts preserve the complete old and replacement workers,
byte range, method/hypothesis/input/output identities, and reversibility check.
They neither compile nor run targets. Existing output directories are refused.
The first is the single-mechanism arm; the second composes with the separately
measured static-image and BANGS-zero arms. Timings belong in the root report.

The old generic `lex` retains its original String and Tuple tests and drops.
Its first self-tail call is fed by a fresh Tuple, so that transition transfers
the two already-evaluated, originally sealed fields into a private loop. The
new loop consumes String exactly as before and retains Mode and accumulator in
two `Term` variables. It does not flatten Mode, eliminate field seals, infer
scalar kinds, remove error checkpoints or introduce recursive C calls.

The generic entry transfers its `nf_poll` counter to preserve poll cadence.
The private loop's invalid-String path recreates the original two-field Tuple
and calls the original parent drop, in the original order relative to the String
drop and error. This deliberately avoids replacing aggregate ownership with an
assumed fieldwise drop on an uncertain raw path. The existing invalid-Tuple arms
remain syntactically present but unreachable at a constructor-proven entry.

Source assertions require exactly one original allocation, three original
`ctr_take` sites, unchanged field seals, unchanged error count and unchanged
checkpoint count. The private loop retains only String's take; its sole Tuple
allocation is the cold error fallback. Replacing the new functions with the
recorded old worker must recover every original input byte.

The earlier counted input cycle allocated **370,509 Tuple shells** in this
worker and 6,144 initial-state Tuples in its caller. The diagnostic predicts
removal of the former, retaining the latter. This is an allocation prediction,
not a speed estimate. Invalid-input controls must supplement the valid lexer
oracle before any production correctness claim.

## Why the existing product route declines this loop

`nq_layout` already resolves the lexer state to the two-field Tuple shell;
its Mode field remains one opaque `Term` and is packed for valid inputs.
`nq_entry_demand` refuses the private `lex` candidate because an invalid String
tag can reach `Efq` without matching the state Tuple. This is deliberate: current
`NC_Binding` records independently owned words, with no retained parent group.
Blindly substituting fields would cause `nc_prepare_env` to drop them separately
on that branch instead of disposing of the original aggregate at its boundary.

Changing `nq_demand_exhaustive` to call String matches exhaustive is therefore
not the implementation. Annotation-derived layout also cannot justify eagerly
destructuring an untrusted unused raw parameter. The public generic entry must
remain, and a private fast entry must require actual constructor provenance.

## Small coherent production slice

1. Retain a group describing constructor identity and the evaluated field words
   in private product lowering context. Use the existing `NQShape` and `NQBundle`
   rather than another independent type-layout query. Its entrance permission
   is a known constructed bundle, never the source annotation alone.
2. Keep the group until the aggregate is matched or passed to another admitted
   product entry. A successful match consumes the group and introduces its
   ordinary field ownership bindings in the same order as the boxed match.
3. At a path that drops the whole group before matching, rebox it at the original
   parent's environment position, then perform the original parent drop. A
   repeated/escaping/opaque use also reboxes before that use. Initially reject
   repeated groups and unknown joins instead of adding unbounded variants.
4. Use a constructor-proven private entry for self-tail recurrence; the existing
   `nf_self_temps`/`nf_self_moves` provide simultaneous field moves and `goto`.
   Keep ordinary raw/scheduler entry and device fallback unchanged. Acyclic
   generic-to-private entry followed by private self-tail loops is stack safe.
5. Feed the same planned representation to the existing admission fixed point
   so a failed optional route never poisons the ordinary worker. Apply the
   context only where a complete ownership-group proof survives.

Likely integration hooks are `nq_candidate`, `nq_match_local`, `nq_call`,
`nq_local` and the private branch of `nc_lower_to`/environment partitioning.
Passing the group in explicit context is preferable to storing trusted facts in
user-forgeable `KDef` metadata. A first bounded implementation is roughly
100–200 lines plus focused controls, estimated 4–8 hours including debugging;
this estimate is uncertain until the proof obligations are exercised. A general
recursive product/sum ABI is substantially larger and unnecessary for this
particular experiment.

Required focused controls: unrelated tail state with owned arrays; field swaps;
matching then dropping one field; ignored whole aggregate; invalid earlier
scrutinee; shared field; escaping result; repeated use; competing errors; and
one/four-thread execution. Existing raw unused-product/error controls remain
mandatory. Correct output without active unboxed recurrence is insufficient.

## What this does not solve

Map's recursive `bit.go` and `seek.go` cross scheduler continuations, and their
upstream counterparts return two and four words. `nq_transfer(..., NC_Scheduler)`
currently reboxes, so a loop-only feature will not close those gaps. Multiword
scheduler transport needs one result-layout plan shared by producers, return
register counts, continuation parameters and raw/closure adapters. Existing
`N_Segment.result`, `N_Param.kind` and `WL_RETN(n)` are useful substrate, but
late rewriting of `N_Segment.body` strings is not a clean general solution.

If the loop diagnostic is weak, do not implement this group machinery merely
because it is elegant. Investigate the measured String construction/destruction
and scheduler-to-worker calls instead. If it wins, apply it to another product
loop before extending the native representation model through scheduler returns.
