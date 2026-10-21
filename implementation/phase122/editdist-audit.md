# Phase122 editdist: the remaining gap is inside a scalar loop

Bounded offline follow-up; no builds, target executions or compiler changes.
Products and hashes are pinned in
`selfhost/build/phase122/manifest01.json`. Fresh clean medians are429ms QBE,
202ms mature self-hosted C and202ms upstream C, or2.124×. The pooled profile
attributes1110/1121 QBE samples to`$product.row`; the first693-sample capture
independently passes the coverage gate. Individual PCs are instruction leaves,
not causal cost estimates.

**What is already working.** The active row at
`selfhost/build/phase118/p121-broad-emit04/editdist.ssa:6111` versions the loop,
hoists three array guards, bases and masks, and has no ordinary calls on its
fast path. The earlier function at`:5409` is the fallback. Its generic array
calls must not be reported as active hot-loop overhead. The source helpers are
inlined and array elements use direct four-byte loads/stores.

**Machine evidence.** `objdump -d --no-show-raw-insn` on the pinned binaries
shows the following normal inner-loop intervals:

| Product | Address interval, end excluded | Instructions | Stack-memory operands | Calls |
|---|---|---:|---:|---:|
| QBE | `0x408490..0x408582` |65|9|0|
| upstream C | `0x7660..0x76bb` |26|0|0|
| self-hosted C | `0xa280..0xa2db` |26|0|0|

These are static instructions for the selected loop bodies, not cycle counts.
Both C loops use essentially the same instruction sequence. This directly
establishes that our algorithm and array semantics can run at upstream speed.

Two differences are concrete:

* QBE materializes and then retests predicates. At`0x408520` the minimum becomes
  `cmp; setb; movzbl; mov; spill; cmp $1; cmovne`. Upstream at`0x7696` and mature C
  at`0xa2b6` use`cmp; cmovb`. The character-cost calculation similarly converts
  a comparison to0/1, compares it to1 and selects0/1 again. The QBE source at
  `editdist.ssa:6554` has comparison, boolean normalization, widening, then a
  generic Bool match. Boxed-Bool high-bit checks have already folded away; the
  remaining truth-value round trip has not.
* QBE computes scaled addresses with separate shifts and retains more temporary
  values. Its hot loop spills/reloads cost, a loaded DP value and array bases;
  the C loops use x86 scaled addressing and register-resident comparisons. QBE
  also retains a distinct countdown alongside the index; the C loops specialize
  to the known256 bound. These differences explain plausible extra instructions
  and pressure, but the audit does not assign fractions of the2.124×gap to them.

**Interpretation.** This is largely a post-inlining scalar canonicalization and
machine-code-quality deficit. There is no evidence here for a missing container
fusion or a hot runtime check that should simply be deleted. The general
lowering initially expands typed predicates into Term/Bool machinery; LLVM
recovers the compact computation for both C producers, whereas the current QBE
path leaves redundant operations. That does not demonstrate a need to adopt
LLVM: the exact predicate identities are small enough to expose explicitly.

**Smallest next experiment.** On a frozen copy of the structured row body,
normalize proved0/1 comparison results through copies, widening, `!=0`, `==1`
and Bool matching; preserve unknown-value fallbacks. Measure this one ablation
before broader range analysis or register-allocation work. Require the emitted
minimum to become one compare/select and inspect whether spills fall. Use
independent unsigned comparison/minimum controls at0,1,2^31,UINT_MAX and branch
joins with unknown words. Keep modulo array-index masks: their removal requires
a separate bounds proof. Existing source/block-count cutoffs and complete
compiler-cost gates remain necessary; Phase120 already demonstrated the cost
of an expensive broadly applied numeric analysis.

If this normalization removes the round trips but leaves most of the gap,
compare register pressure/address formation next. The static evidence supports
a cheap decisive experiment, not a promise that65→26 instructions can be
obtained or that timing scales proportionally.
