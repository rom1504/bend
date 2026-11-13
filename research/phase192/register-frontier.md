# Phase192 control-value frontier

The next broad step is **retaining predicate meaning through copy diamonds,
Boolean combinations and structured control flow before register allocation**.
The allocator currently spends real homes and instructions on materialized
Boolean intermediates which the mature C product represents as direct control.
Start with the small normalization slice below; a complete predicate graph and
path-fact implementation is a separate expansion, justified only by its screen.

This inspection used current Phase191 `native45-02` x86 executables and the C
products named by `selfhost/build/phase191/references01/manifest.json`. Only
`nm`, `objdump`, Python metadata inspection and C syntax checking ran. No
inspected executable or compiler ran in this research task. The existing final
Phase191 physical profile supplies Map hotness; other witnesses are static
regions in source-level repeated workers, without new dynamic attribution.

## Concrete witnesses

| Product and function | Exact current x86 region | Observed unnecessary representation boundary | Mature C comparison |
|---|---|---|---|
| Map-32, `$p118borrow.read.Map.bit.go` | `0x40705f..0x407080`, then `0x407080..0x4070d6` | After successfully checking tag 25, the next 20-instruction region extracts arity and reconstructs the same tag predicate, materializes both booleans, combines them and tests the result. The prior tag extraction/check costs another six instructions. | `WL_FID_$direct.Map.bit.go`, loop `0x166e0..0x1672c`, keeps the decoded tag test at its loop edge and directly branches. Required heap-layout cases remain. |
| lexer, `$product.lex` | `0x40c841..0x40ca84` | Classification region has 127 static instructions, 10 setcc and 10 cmov instructions, with three conditional branches. Comparison values repeatedly become selects of 1/0 and then comparisons with 1. Several final selects have identical tagged constants in both arms. | `$direct.lex`, `0xad31..0xad7b` plus branches around `0xaed9..0xaef5`, classifies with direct range compares/branches and one conditional move. Its ownership/layout work outside classification is substantial. |
| tree-bitonic, `$direct.warp_leaf.go` | `0x408971..0x4089c8` and `0x408ae6..0x408b37` | 19-instruction Boolean decode/complement/test followed on one edge by the same 18-instruction decode/test. Each decode supports immediate and tagged Boolean forms. | Corresponding C worker starts `0xded0`; decision is `cmp $1,%ecx; jne` at `0xded5/0xded8`. The function is 195 bytes versus x86 843 bytes, but constructor/ABI differences also contribute. |
| BST-32, `$product.bst.pick` | `0x408751..0x4087a2`, `0x40885d..0x4088b4` | Same 18+19 instruction repeated Boolean decode on opposite arms. | C `$direct.bst.pick`, `0xbef1/0xbef5`, uses one comparison/branch. Function sizes 453 versus 768 bytes include unequal product-return conventions. |

The lexer count includes alternative paths and is **not** 127 instructions per
character. Its source `cls` computes two range predicates and one equality;
`cls.go` prioritizes letter, digit, space, punctuation. No ASCII-only assumption
is needed: inputs remain U32, including values above Unicode's usual range.

Current executable SHA-256 identities:

```
coverage-map-churn-32 c78160cc20bd112b2dec064b9f71abc832022cc3740379a5a7c5abc25dc69089
lexer                 2e16936fb1b57473b8928f7948f52136881c94482ecba7385e5960310c73576e
tree-bitonic          efc059c07ae4742b62f3ce3ec63946ecd461ccb33f421498de3725a1856ef795
coverage-bst-32       74f594f1d0a661b4d4409c4cdc07001474d5d97abdb2a6e01993c7683cfedf53
```

Paths are `selfhost/build/phase191/native45-02/CASE/machine/program`.
Reproduce each witness with `objdump -d --no-show-raw-insn --start-address=A
--stop-address=B PATH`; the full symbol is recoverable with `nm -S` and decimal
`FID_` character decoding. C products are under
`selfhost/build/phase184/bend-products01/CASE/bend-c/program`, as bound by the
Phase191 reference manifest.

The final profile attributes 10.96% of Map-32 samples to borrowed bit traversal;
the complete leaf's zero-cost ceiling is only about 11% total time. Predicate
normalization can save a fraction of that leaf and also apply in generated
callers. This is not evidence for removing ownership or heap-layout checks.

## What is missing today

`loop-liveness.bend` admits 32 candidate names and installs one home per name;
the joint allocator refuses bodies above 256 statements. Splitting large Map
functions remains plausible, but its large static frame counts do not establish
dynamic benefit. I did not select regional allocation for the first experiment.

`register-binary.bend` already uses direct physical operands and protects right
operand aliases. `expression-reuse.bend:x190_v_body` has local copy/width facts,
but resets facts at every unresolved branch and call. The branch selector
requires adjacent comparison/If pairs and its complement simplifier examines
only an arm head. It does not retain an expression for a composite predicate.
`conditional-select.bend` converts copy arms to machine cmov after placement;
it preserves every write and does not normalize the resulting Boolean value.

Thus this is a control-value representation issue, not another call-move
cleanup. The rejected approximately 0.56% argument-move experiment remains
rejected; none of its static savings are credited here.

## Bounded first implementation, authored separately

`selfhost/src/back/x86/predicate-normalization.bend` adds
`x192_predicate_body(body)` before existing local-value propagation/allocation.
It tracks the exact invariant **integer value is 0 or 1**, not generic truth.

* Comparison outputs, copies, and Boolean and/or/xor preserve that fact;
  every local overwrite replaces its own fact. Loads/offsets/allocas remove it.
* A certified pure copy diamond selecting 1/0 becomes a copy of a known exact
  predicate; 0/1 becomes xor 1. Arbitrary nonzero U64 values are not predicates.
* Identical pure copy arms collapse while preserving every original destination
  write, width, order and snapshot. Existing `x191_select_plan` bounds chains
  to four destinations and rejects effects, unequal writes and mixed widths.
* Equality/inequality of an exact predicate against 0/1 becomes copy/complement.
* Calls and unresolved joins forget facts. The pass performs no load/store/call
  motion, no loop hoisting, no Boolean ABI rewrite and no speculative execution.

`predicate-integration.patch` is supplied separately for the existing function
pipeline. Root owns canonical module registration, checked source assembly and
actual measurement. This first slice will not remove Map's repeated tag test or
the tree helpers' generic Boolean decoding: those require expression/path facts
or a proved typed private-ABI contract. It directly tests whether avoiding the
lexer's redundant Boolean round trips is economical before that larger work.

Controls are `selfhost/tests/phase192/predicate-controls.bend`, independent
`predicate-controls.c`, and `controls-predicate.mjs`. Eleven shape cases include
overwritten predicates, noncanonical truth, calls, loads, joins, in-place copy
chains, equal arms and complements. The C observer checks 1,331 input/mode
combinations per machine route, including 2^32, 2^63 and UINT64_MAX, and observes
every destination plus source-memory preservation. C syntax checking passed;
checked Bend acceptance and machine observations are pending root's serial lane.

## Cheap falsifier and economic bounds

1. Check the candidate source and finite controls. Inspect `$product.lex` in an
   actually emitted product: the cmp→1/0-select→cmp round trips must disappear;
   record branch/cmov counts, positive path lengths and retained ownership calls.
2. Run a balanced small screen including lexer, lexer variation, Map-32,
   tree-bitonic, BST-32, expression-32, local-pair and a numeric control. Reject
   this slice if it only removes unused workers, leaves the repeated lexer
   classification intact, changes any noncanonical truth result, or produces no
   credible runtime win. Do not proceed to whole-function regional allocation
   merely to rescue a negative result.
3. If the slice wins, the next increment is a bounded typed predicate DAG with
   mutation versioning and branch environments. Carry an exact outer tag fact
   into the taken arm; lower Boolean combinations directly to branches, and
   materialize 0/1 only at actual value consumers. Preserve required arity,
   layout, ownership and malformed-value behavior. Only later consider a typed
   private Boolean calling convention for the tree witnesses.

The first slice could plausibly save 5–20% in lexer classification-dominated
cases, but zero or a regression is credible. Its whole-suite hypothesis is
**0–3%**, not an architectural parity claim. A fuller predicate/path pipeline
with measured coverage across text, tree, Map and control-heavy general cases
has a speculative **3–10% whole-suite** reduction range; no current evidence
justifies promising more. At the current 2.7366× C ratio even 10% yields about
2.46× C. Broader gains must compose with arithmetic/runtime-dispatch and
representation work, with independent ablations. Static instruction counts and
different C allocation/ABI choices cannot establish those runtime percentages.
