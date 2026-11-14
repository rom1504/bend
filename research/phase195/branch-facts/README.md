# Incoming value facts through branches

This experimental candidate carries the existing `X190Values` state into both
arms and retains only incoming facts whose names survive both original arms.
It changes one function, `x190_v_plain`, through a source override. Maintained
compiler source, structural verifiers, scalar operation semantics, allocator
and ordinary effect order are unchanged. No compiler/target job ran during
authoring; checked-source acceptance and machine validation remain root-owned.

## Scope and correctness argument

`x190_local_values_body` already performs typed scalar substitutions and
canonical U32 copies after the original lowering/verification boundary. Its
existing limit is512 combined setup/body rows. No provenance rule requires
unchanged row bytes: the existing pass and downstream dead-assignment pass
already change rows. This experiment does not claim a new proof from that fact.

The incoming aliases describe full-word value snapshots, not memory-load facts.
Each arm uses exactly the existing scalar rewrite and per-write invalidation.
An assignment to a source kills aliases that point at its old value; writing an
alias destination kills that destination's mapping. Flattened aliases avoid
transitive invalidation through an untracked chain. Original Set instructions
remain, including necessary U32 truncation; only the existing later liveness
pass may remove an unused snapshot. No effects or memory accesses are moved.

At the join, `x195bf_join` scans the **original** yes and no arms, sequentially
applying only kills to the incoming state. It does not merge arm-exit states or
infer newly equal branch results. Set/Bin/Offset/Load/Alloca destinations use
`x190_v_written(name,False,...)`, which kills destination/source aliases and
zero-extension knowledge for that written name. Nested branches union their
kills. Any call, return, Result or Again clears all facts conservatively. Stores
preserve scalar facts, as in the existing pass; scalar local values do not alias
the contents of an addressed allocation. Width knowledge of an unchanged
snapshot remains valid even if its original source is later changed.

Only branch dispatch in `x190_v_plain` changes. Its other cases are copied from
the original. `x190_v_body`'s existing arithmetic/mask matcher, `x190_v_set`,
`x190_v_written` and old `x190_v_if` remain untouched. Setting
`x195bf_enabled=false` uses the exact old branch behavior, including recursive
branches. Nested kill scans can cost quadratically in the bounded body size;
the unchanged512-row entry limit prevents an unbounded new analysis. Actual
compiler-request cost is still required before promotion.

## Concrete hot opportunity

[`hot-alias-witness.json`](hot-alias-witness.json) pins the actual allocation
capture for hot `p113d_FID_$product.row` (99 selected rows, not the167-row
fallback). It retains three full U64 snapshot/consumer corridors:

- `...p113p_move_25_0` aliases the latest `...value` before the first min's false arm.
- `...p113i_0_result_0` aliases the first min's `...p113p_call_13_0` before the second min's true arm.
- `...p113p_move_33_0` aliases the latest `...value` before the second min's false arm.

The capture shows no alias/source writes between each definition and consumer,
or within either consumer arm. Current resets nevertheless hide these aliases
at branch entry. In the actual Phase194 machine, the second min loads the
snapshot homes at`0x40cc16`/`0x40cc1d` before CMOV and publishes another stack
result. The new source pass should expose original values to the existing
selector/liveness pipeline. This is a falsifiable prediction: only actual new
emission can show which homes, stores or loads disappear. Static witnesses do
not establish dynamic counts or speedup.

## Acquisition and controls

Prepare from the exact frozen Phase194 selected-source02 using the unchanged
Phase190 API preparer, with modules:

1. `selfhost/tests/phase195/branch-facts/branch-facts-v2.bend`
2. `selfhost/tests/phase195/branch-facts/hook.bend`
3. `selfhost/tests/phase195/branch-facts/controls-v3.bend`

Use only `--replace x190_v_plain`; append exports
`--export p195bf_controls --export p195bf_emit` to the seven default API roots.
Root prepares fresh source/binding/export and checked-API receipts. Run
`driver-v3.mjs` with the existing `--api`, `--assets`, `--source-manifest`,
`--out` and bounded `--seconds` arguments under root's single outer guard.

Twenty structural controls cover source writes in either arm, destination
writes, nested branches, call/Again/Result invalidation, store preservation,
width kills, refusal to learn new join widths, unknown-high-bit U32 snapshots
and known-canonical aliases. Thirteen actual machine functions cover both arm
outcomes, incoming-arm use, postjoin rebinding, nested branches, narrow-copy
snapshots, alias chains, branch-defined fresh values, an external call and a
load overwriting an aliased source. V3 additionally tests a known-zero32 incoming
alias used inside an arm before source rebinding, a full-word transitive alias
whose intermediate is overwritten, and the scalar `N111If` representation.
The independent C observer checks all
9×9 full-width input pairs, both conditions and all thirteen functions: 2106 checks
per direct/rendered route, including returned results and memory effects.
The C observer passed strict syntax checking only. No machine result is claimed.

`driver-v3.mjs` reuses the existing physical-selection transport, changing only
fixture specification and report kind. Both routes come from the same typed
selection, not an independent third compiler. Earlier `controls.bend` and
`driver.mjs` are preserved: their machine entry called `x191_ordinary` directly
and bypassed the value-fact pass. **V2 and v3 call the full
`x185_function_setup` pipeline and can test this hook in emitted machines.**
V2 still contained a computed match scrutinee rejected by the current parser;
v3 replaces it with a typed helper parameter and annotates all local lists and
state bindings. Only v3 is ready for the next source-acceptance attempt. Do not
include multiple versions' duplicate definitions in one source.

The v3 offline audit checks all core/hook/control match scrutinees are simple
parameters, no local binding precedes a match, delimiters balance, all local
lists have explicit types, and all 20 structural labels match the driver.
Every new constructor is in a typed return, typed local or typed constructor
field context. `controls-v3.c` passes `gcc -fsyntax-only -std=c11 -Wall -Wextra
-Werror`. These checks do not substitute for Bend acceptance. V1/v2 artifacts
and prepared API sources remain unchanged; no v1/v2 API acquisition ran.

The subsequent branch-api03 source check rejected the original core because
`x195bf_if` captured affine `condition` and `rest` in both `nt_choose` closures.
`branch-facts-v2.bend` changes only these two parameter annotations to reusable
`+condition` and `+rest`. The original core and frozen API sources are preserved.
The complete closure and shared-binding audit is in
[`affine-audit.md`](affine-audit.md); fresh Bend acceptance remains required.

After these controls pass, emit the ordinary editdist input and compare the
exact hot row's snapshot/reload chain, then at least tree/lexer and a held-out
ordinary case before any full compiler build. Retain alias rebinding, mutable
width, external-call and loop-backedge refusal evidence. If these aliases are
recovered but the target chain or complete runtime does not improve, preserve
that result rather than widening the scope to rescue the hypothesis.
