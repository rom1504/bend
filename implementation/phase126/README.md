# Phase126: keep representations useful across optimization boundaries

Final integration is in progress. Source32 is frozen; the checked hosted API,
98 finite checks and nine ordinary native programs pass. N1 builds and passes
focused19. The native campaign stopped at its storage reserve before self-emission;
the failed receipt is preserved. Original45 timing and the resumed native chain
must finish before this report can claim broad gains or native qualification.

[Design](../../design/phase126/persistent-private-values.md) ·
[Reproduce](../../selfhost/tools/performance/phase126/README.md) ·
[Architecture](../../docs/self_hosted/representation-composition.md) ·
[Semantic review](final-semantic-review.md) ·
[Next opportunities](remaining-opportunities.md).

## What changed

The useful capability is composition: retain information that an existing pass
already established so the next pass can remove a whole boundary. The selected
compiler is still checked Bend emitting QBE directly. There is no generated C or
cproc stage; one small arithmetic helper is added to the cached runtime.

1. **Persistent local floats.** Keep F32 machine temporaries across admitted local
   operations, preserving rounding and explicit observation boundaries. Function
   calls retain the original full-Term ABI. The typed-private-ABI experiment was
   slower and is excluded. This is not fast-math or a promise about arithmetic
   NaN payloads beyond the stated transport/conversion controls.
2. **Finite scalar selectors.** Evaluate small closed selectors into verified
   readonly tables, then project their reads into consumers. Keep the full-width
   default, exact supported operations and a bounded admission policy. Effects,
   nonfinite intermediate values and unknown expressions retain fallback.
3. **Recursive computation composition.** Admit already-safe conditional argument
   preparation into the existing explicit-stack regions, and project the exact
   Nat predecessor operation. A small local admission now unlocks a much larger
   ray computation; stack safety continues to use the existing continuation stack.
4. **Flat observer products.** Give an existing certified borrowed reader a flat
   result interface, then rerun dependency closure with that interface available.
   The production hook matters: merely creating a helper did not activate the
   optimization at the integrated entry point.
5. **Unboxed quotient/remainder.** Authenticate the native Nat.divmod application
   and return its two full-width results in a local 16-byte buffer. This removes
   a temporary heap Tuple, its construction and take. The exact new runtime
   import preserves divisor-zero behavior `(0, dividend)` and performs no
   ownership operation. A final publicly observable Tuple still materializes.
6. **Two-member tail cycles.** Join exact mutual tail calls into one existing-IR
   loop with word arguments and a discriminator. Original wrappers retain their
   interfaces. Exact call/result identity, hygiene, arity and final verifier
   checks remain mandatory; unresolved and non-tail cycles retain fallback.

The selected source SHA256 is
`40c469114c4d1c75dceab456e1979bb5c0278744a02e6dbe4a37e63667740abb`.
[Its compressed source](compiler-source32.bend.gz) is independently recoverable;
the manifests retain the module-by-module derivation and protected declarations.
Source33's extra optimizer composition is excluded.

## Focused findings before the broad gate

These are three-round, fixed-repetition screens, not a pooled corpus score.
Numbers are generated-program runtime in milliseconds, candidate / same-run
Phase125 / pinned upstream C-Clang.

| Selected capability screen | Candidate | Phase125 | Upstream |
| --- | ---: | ---: | ---: |
| Ordinary ray, numeric composition20 | 374 | 1913 | 230 |
| Active ray256, numeric composition20 | 769 | 1696 | 200 |
| Numeric recurrence, composition20 | 303 | 418 | 201 |
| Record aggregation256, final32 | 567 | 684 | 200 |
| Map churn128, final32 | 653 | 712 | 200 |
| Evening program, final32 | 1292 | 1382 | 211 |
| RLE, final32 | 1130 | 1145 | 202 |
| Lexer, final32 | 504 | 521 | 192 |

Composition20's numeric changes are included in final32, but its measurements
remain measurements of composition20 until the final broad run checks them.
The final32 five-case geometric ratio is0.92537×Phase125 and3.83755×upstream;
its difficult subset is not the original44-point metric.

Machine inspection explains specific work removed. The recurrence worker has
60→40 instructions,9→0 stack-memory operands and9→2 integer/XMM transfers.
Neither version called a runtime helper there: operation admission unlocked the
entire local float buffer. The ray column worker loses a Nat helper boundary
and six stack operands. All five inspected final programs contain joined
Nat/U32 read/format tail workers with local backedges and no mutual native
recursion. See [numeric machine evidence](machine-work14-17.md),
[product evidence](product-observer-report.md) and [SCC evidence](tail-scc-machine-review.md).
Static counts establish changed code, not each mechanism's runtime share.

## Correctness and qualification boundaries

The checked API and combined98 finite predicates pass. Nine ordinary native
programs pass152 exact output lines, including float boundaries, table defaults,
full-width Nat arithmetic, zero-divisor divmod, ownership aliases and deep mutual
recursion. The SCC controls exercise200002 internal transfers with full-width
arguments and an aliased String. Their three forward-calling helpers use the
language's explicit `@unsafe` permission for user forward laws; this does not
relax the IR verifier or prove general termination. Earlier invalid fixtures
remain preserved with their original failures and unchanged expected outputs.

The native ABI is source-bound and retains the previous runtime prefix and
verifier fallbacks. Seven data-only mutations are refused. A complete native
checkpoint additionally requires hosted→N1→N2, byte-identical raw QBE, both
focused19 suites and N2's original45 correctness suite. ABI admission or hosted
success alone cannot substitute for these obligations.

The native one-shot45 sources and the timed batch45 sources have different
entry points:0/45 source hashes match. They are deliberately separate gates.
The installed JS/native selection remains unchanged. There is no N2→N3, ELF
fixed-point, GPU/parallel or recursive-research-acceleration claim.

## Costs and rejected alternatives

Two matched hosted compiler requests cost **1.08745×Phase125** overall and
1.13212× for the admitted entry, using the unchanged paired method. RLE grows
4.221→4.639s and lexer8.055→8.668s. These are compilation costs, not user-program
runtime or native B1/B2 throughput. Static inspection identifies repeated late
candidate preparation as a cleanup opportunity; it does not attribute the
measured overhead without a profile or ablation.

The compiler source grows53,219→55,285 physical lines: **+2066 lines,+3.88%**,
including controls. Bytes grow2,429,750→2,527,616. The runtime gains594 bytes.
This cycle improves capabilities at a real simplicity and compilation-cost price.
It does not establish a simpler compiler or lower research cost overall.

- **Typed private float ABI:** local-only values win the paired ablation
  (active ray1175ms local,1297ms typed,1712ms parent). Keep the simpler choice.
- **Tree-shell reconstruction:**5630/5630 guarded attempts succeed and Node
  allocator calls fall37.92%, but runtime regresses5.47% and3.35% in two variants.
  The old freelist already recycles those cells. Fewer allocator calls do not
  establish less fresh memory traffic; cache-placement effects remain unmeasured.
  Both variants are excluded. [Full negative result](tree-reshape.md).
- **Initial divmod hook:** all five programs were byte-identical to the parent,
  because the hook missed the authenticated App form. Static activation inspection
  avoided wasting a timing campaign; source32 fixes that boundary.
- **Source33:** extra bounded optimizer composition changes few private workers;
  lexer/RLE QBE remains byte-identical to32 and the separate five-case score differs
  only about0.3%. That does not justify its extra machinery;32 remains selected.
- Earlier rejected constant-field/constructor adapters and parser/type/law fixture
  failures remain in the evidence. No correctness gate was weakened to accept them.

## What the ambitious path taught us

The larger experiment was to compose representation, borrowed products and local
control flow using existing verified interfaces. It produced useful general
capabilities without replacing the whole IR. The negative tree experiment also
prevented promoting an attractive but slower cross-layer transformation. Neither
result justifies a universal IR rewrite or a parity forecast.

The strongest next experiment is the **outer Map continuation boundary**. Actual
final32 machine code still takes and reconstructs MNode roots, saves frames and
jumps to boxed Map.bit even though a useful flat helper exists. Preserve that flat
result through its immediate return consumer first; test a renamed binary search
with aliases/missing keys and an unrelated consumer before widening its ownership
schema. A second bounded task can skip already-ready flat candidate preparation
and require byte-identical QBE to recover compiler overhead. See
[ranked opportunities and falsifiers](remaining-opportunities.md).
