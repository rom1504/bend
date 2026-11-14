# Integer selection inside FloatNodes: bounded composition v1

Actual table-v3 ray code removes the helper calls but still emits SETB/MOVZX/TEST/branches for each clamp. The floating node emitter bypasses the existing ordinary predicate consumer: `x186_x_emit_node` handles `FloatPlain` through `x181_stmt` and `FloatBranch` through `x186_x_emit_if`. Physical v2 alone cannot fix this route.

## Consumer contract

`float-compose-v1.bend` overrides only final `x186_x_emit_frame` through the separate hook. Allocation, float pruning/renaming, XMM homes, frame construction and the final program verifier remain unchanged. The enabled=false route calls the exact previous frame emitter body under `x195fc_frame_previous`.

A candidate consists of exactly two adjacent nodes: an actual `FloatPlain(N111Bin comparison)` followed by a `FloatBranch`. Each arm must consist solely of at most four actual Plain Set statements. These actual source rows are passed to the existing `x194_ps_pick`, including its existing signed/unsigned and independently selected-width checks. No FloatValues node or its placement stand-in is ever fed to an integer matcher or optimizer.

Every comparison operand, selected choice, destination and removed predicate name must lack an XMM home. This is checked explicitly rather than inferred from current allocator behavior. Every selected load and publication therefore uses the original ordinary GPR/frame word representation. Nonselected FloatValues and U64-copy nodes continue through the original `x186_x_emit_node`, preserving its XMM publication semantics. Ordinary fallback branch label creation, terminal/error handling and recursive arm order are retained exactly.

Whole-function read counts are collected directly from actual nodes: Plain reads use the original collector, FloatValues contribute their actual left/right reads, and branches include condition plus both arms. Pair counts come only from the exact two-node candidates above. The existing `x194_ps_allowed` complete-use certificate checks these counts plus original parameter/setup protection. Thus a predicate also read by floating arithmetic, an effect, a result, or an unrecognized corridor refuses. Repeated mutable predicate names are admitted only when all their reads are accounted for. The unused writes field is empty; this consumer only calls the existing predicate certificate, which does not inspect that field. The existing selected emitter `x194_ps_emit` determines machine code; composing physical v2 changes only that already-isolated dependency.

## Finite controls and integration

Use module/hook v1, `float-compose-controls-v2.bend`, `float-compose-controls-v1.c`, and `float-compose-driver-v2.mjs`. V1 fixture is preserved; v2 adds the required affine annotation on the mode used by nested-branch generation. Include Phase194 `predicate-controls-v3.bend` for existing predicate/operator helpers. Export `p195fc_controls` and `p195fc_emit` alongside normal compiler/encoder roots.

Forty actual `x186_x_place` functions cover ten signed/unsigned comparisons and all U32/U64 compare/result-width combinations. Outputs alias both inputs. Half place the corridor inside a nested branch. Real F32 add/multiply and canonical copies surround the corridor; the independent C observer checks both selected words, return value, unchanged input memory and both exact 6.0f words. Structural controls also require an actual XMM home in the surrounding region and test XMM operand/predicate, protected parameter/setup, floating external predicate read and FloatValues-arm refusals, plus repeated predicate definitions. There are 4840 edge-pair observations per direct/rendered route; both routes share typed emission, with independent C expected values.

Only source-local delimiter/computed-match review and driver syntax checks have run in this lane. Root owns checked API, machine controls, actual clamp disassembly, runtime and compiler-cost measurement. No maintained source is changed. A successful composition should remove clamp branches in actual ray code, but no speed estimate follows from that expectation.

## Source-check failure and versioned correction

Root's `table-compose-api01` source check rejected v1 at assembled line52502: `stmt` was matched after a later binder. In `x195fc_pick`, the outer pattern had already matched constructors in the later tail (`Con(FloatBranch(...))`) while leaving the earlier statement opaque; matching that statement afterward violates Bend's ordered matching restriction. The earlier source-local checks covered delimiters and computed scrutinees, not this restriction, and were insufficient.

Use **float-compose-v2.bend + float-compose-hook-v2.bend** with unchanged controls-v2 and driver-v2. V2 flattens the actual compare statement into the original pattern and reconstructs the same statement for the existing matcher. It also removes both other nested matches, in arm extraction and selected-plan emission. All remaining matches in this module and controls are at function entry, on function parameters in their original order; none follows a local statement or rematches a previously inspected binder. This is source-local review, still subject to the root-owned checker. V1 files and failed acquisition are preserved. Admission, width, read-count, XMM and publication contracts are unchanged.

## Frozen-parent closure correction

`table-compose-api02` progressed beyond module syntax and rejected the fixture's call to `x186_x_place`: that maintained helper is absent from the final194 seven-root source closure. Use **float-compose-controls-v3.bend + float-compose-driver-v3.mjs** with unchanged module/hook v2 and C observer v1. Emission now uses the actual in-closure `x194fv_place`, following identity preparation → `x186_f_place` allocation → `x186_x_select_frame` → hooked final emission. `x185_function_setup` takes raw P113DStmt and is not a type-correct entry for this already-typed FloatNodes fixture.

Every positive mode now requires exactly one admitted selection in its actual identity-prepared whole-node tree, using the actual XMM home map and complete function facts. The XMM-positive control checks the same prepared nodes. This checks that nested cases and surrounding real FloatValues reach the intended consumer without treating missing XMM homes as sufficient evidence.

The source-local reference audit in `float-compose-reference-audit.json` pins the frozen parent and all additions. All93 call identifiers resolve either to declarations in that exact closure/additions/included predicate helper fixture or to12 prelude functions already used by the checked parent. There are no missing call identifiers. All module/control matches remain at function entry; driver syntax and delimiters pass. This audit is not a sourcecheck or a generated-program pass; root-owned validation remains authoritative.
