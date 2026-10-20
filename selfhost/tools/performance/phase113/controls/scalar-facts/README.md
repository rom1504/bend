# Independent scalar-fact controls

Root runs the current frozen method under its serial process-tree guard:

```sh
BUN selfhost/tools/performance/phase113/controls/scalar-facts/controls-v2.mjs \
  CHECKED_API_WITH_p113k_optimize selfhost/build/phase113/FRESH_SCALAR_FACT_CONTROLS
```

`manifest02.json` preserves the original method and adds the law review's exact
constant-shift and nested scalar-branch cases. The 78 bounded groups compare
before/after/twice-transformed IR against an independent mathematical integer
and runtime-call-trace model. The edge set includes 0, 1, 2^31, 2^32−1, 2^32,
2^40, 2^48−1, 2^63, 2^64−1, the actual packed True word and raw NaN bits.
The model never derives expected values from compiler optimization helpers.

Coverage distinguishes full U64 Terms from `N_W32` ownership metadata, exact
low/high words, U32 operation width, signed/unsigned comparisons, masks, both
branch forms, terminal-arm joins, reassignment and load/call invalidation,
loop-carried parameters, and observable keep/sink/store ordering. A second
optimization application must retain semantics; syntactic idempotence is not
required. Four proven-range witnesses must also remove the high-bit shift,
so a no-op optimizer cannot satisfy every gate.

QBE1.3 `doc/il.txt`, lines 698–703, specifies modulo shift counts. The frozen
source pin records that primary authority. Raw QBE `shr` by64 therefore acts
like shift0 for a U64 operand. Bend `U32.shln` has its own guarded semantics;
these are deliberately different layers. Exact shifts and arithmetic-shift
sign extension are interpreted with the IR operation's actual U32/U64 width.

The synthetic original programs must not execute natively. These are finite
model/property observations, not arbitrary-program equivalence or ownership
proofs. Native ownership and semantic evidence remain separate.

`native-manifest01.json` freezes an actual Bool/Nat/record source and twelve
independently calculated output lines. First run the shared
`controls/frontend-preflight.mjs` against that manifest to establish source
acceptance cheaply. `prepare-native.py` then prepares baseline/candidate direct
emission, build and exact-observation jobs, using the same arguments as the
inliner preparer. Source syntax cannot prescribe packed Bool storage; the
native source tests logical behavior while raw IR supplies the packed-word
boundary explicitly. No target was executed by the control author.
