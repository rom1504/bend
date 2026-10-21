# Phase123 canonical predicate audit and prototype

Source-only audit; checked API acquisition and target execution belong to the parent lane. No runtime or verifier change. Parent is the Phase121 source04 specified in Phase122's evidence manifest.

## Evidence and exact identity

Phase122's editdist audit identifies the fast versioned `$product.row`, not the fallback:65 machine instructions and9 stack-memory operands versus26/zero for both mature selfhost C and upstream. The native source at `selfhost/build/phase118/p121-broad-emit04/editdist.ssa:6554` contains this general sequence (names abbreviated):

```
p =w cultl a, b
q =w cnew p, 0
wide =l extuw q
copy1 =l copy wide
copy2 =l copy copy1
again =w ceql copy2, 1
jnz again, yes, no
```

`p113bq_emit` creates normalization+widening for the structured 1/0 diamond. The original structured operation is `N111If{p,[wide=U64 1],[wide=U64 0]}`. Every comparison has a U32 result even when its operands have U64 width (`p111v_schema_stmt`, `p113k_result_type`). Thus the entire truth-value round trip can refer directly to the original comparison's U32 result while it remains live. The inverse diamond yields `p xor 1`. This applies to any verified comparison and exact Boolean diamond, without workload names.

Phase120 Boolean01 incorrectly copied a U64 local into a U32 destination. Exact-width validation rejected the transformed functions; fallback restored expensive unoptimized code. Boolean02 preserved operand widths but merely changed equality-to-one into inequality-to-zero; it produced no demonstrated further benefit. The present prototype recovers the *original U32 producer*, so neither limitation applies by construction. Measured benefit remains unproved.

## Minimal implementation and interface

`selfhost/tools/performance/phase123/predicate/model.bend` overrides exactly `p113l_record` and `p113k_scalar_bin`; unchanged originals are included under `p123p_old_record`/`p123p_old_bin`. It runs inside the existing bounded range scan, after inlining and before the unchanged `p114s_commit` full-function verifier. No separate whole-program traversal or new IR is introduced.

A private `@p123predicate:` index record stores root U32 local, root epoch, destination epoch and inversion bit. Only an actual comparison result seeds a root. Copies preserve the root when its epoch remains unchanged. The exact `p113bq_scalar` single-assignment 1/0 diamond records its destination's relation to that root. Equality/inequality with full-word constant0 or1 can then become `N111Set{destination,U32,root}` or `N111Bin{destination,U32,xor,root,1}`. Original result width is therefore unchanged; unknown wide inputs never justify narrowing.

The ordinary range pass still runs and records the exact same result bounds. Original branch/ownership/effect statements remain; this experiment only removes redundant scalar re-tests. QBE must subsequently expose compare/select without spills to support the proposed mechanism. If the root stays live but the two branches still resist machine if-conversion, this prototype may be neutral and should be rejected rather than expanded blindly.

## Soundness boundaries

- Root and destination epochs invalidate every reassignment and call-result overwrite. Comparisons seed only U32 roots; N_W32 hints, low-word masks and arbitrary loads do not seed facts.
- Existing `p113k_join` discards these additional records. No optimistic cross-branch relation merge is attempted.
- A recognized scalar diamond modifies exactly one destination and has no calls, memory writes or additional statements. It can safely recapture the root's post-join epoch only if that root has a different name. This handles epoch resetting at a join without assuming arbitrary branch mutations are harmless.
- Full comparison constants require highword0 and lowword<=1. Nonzero upper words, unknown values, unrecognized diamonds and generic boxed-Bool representations retain original code.
- Original instruction ordering and evaluation are retained. Root locals cannot be addressed through native scratch pointers; only locals/destination writes change their values. Loop scans begin from the existing empty fact state.
- The preexisting4096-statement budget bounds epoch updates; no epoch wrap is approached. Fact entries are bounded by existing definitions, with no catalogue cache.
- The existing original and transformed whole-function verifiers remain mandatory. No verifier weakening and no acceptance based only on emitter output equality.

`controls.bend` exports `p123_predicate_controls(): List<String>` for exact transport/inversion, root overwrite refusal, unknown source refusal, conservative branch refusal, highword refusal, and original/after full-function verification. Parent should also run ordinary source unsigned minimum/character-cost controls at0,1,2^31,UINT_MAX, then inspect editdist's active machine loop. These are finite controls, not a whole-compiler proof.

## Follow-up review and first machine result

The parent lane reports first-screen editdist278ms versus428ms parent and201ms upstream; recurrence419ms versus418ms parent. These are screening measurements, not broad qualification or a compiler-cost result.

Offline disassembly of `selfhost/build/phase111/p123-predicate01-editdist-build/program` confirms the active row loop at `0x4082f0..0x4083a4` (end excluded): **49 static instructions,4 stack-memory operands,0 calls**, compared with Phase122's65/9/0. The two minimum selections are now `cmp; cmovae` at `0x40836d` and `0x408382`; the previous materialize/widen/spill/retest chains are gone. The character-cost path still contains `setne; movzbl; xor1; ... cmove`, so this does not claim complete predicate cleanup. Array masks/address shifts, some widened values, countdown and4 stack references remain. Source-level minimum cleanup is directly supported; the49→26 remaining instruction difference is not automatically recoverable gain.

A second bounded correctness review found no concrete stale-root defect. `p113l_base_scalar` updates epochs for Set, Bin, Call, Load, Offset and Alloca; `p113k_kill` updates direct-call result destinations. Stores cannot mutate native local registers. General branch joins discard predicate records, terminal joins retain only the continuing path, and the one reconstructed diamond relation has exactly one side-effect-free destination. Width validation still checks the original function and the transformed function. The parent's added independent BigInt evaluator checks600 unsigned boundary pairs and literal expectations; execution remains parent-owned.

## Exact-output cost variant

`model02.bend` preserves the original model and changes only evaluation order of pure necessary guards. In model01, strict `&&` caused two epoch lookups even when `p123p_get` found no origin record; copy handling also looked up a nonexistent root, and comparison handling fetched origins before rejecting a non-equality opcode or non0/1 constant. Model02 uses lazy `nt_choose` guards so these refusals stop first. Accepted facts, widths, rewrites and join behavior are unchanged; no additional pass or cache is introduced. Expected benefit is lower refusal overhead, not better generated code. Require identical small-pair emitted QBE and paired hosted compiler-cost measurements before choosing this variant. No cost claim has been measured by this audit.
