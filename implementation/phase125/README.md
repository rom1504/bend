# Phase125: owned composition and a new native checkpoint

The final checked-hosted producer improves the original44-point geometric runtime
ratio from **1.92031× to 1.89221× upstream** in the same run: **1.46% less time**.
All405 complete-result/count observations pass. This is useful but small broad
progress; it does not establish parity. A separate fresh-list transfer improves
241→163ms, or32.37%, and is excluded from the historical score.

[Design](../../design/phase125/owned-composition.md) ·
[Reproduce](../../selfhost/tools/performance/phase125/README.md) ·
[Semantic interface](../../docs/self_hosted/owned-native-composition.md) ·
[Optimization findings](optimization-findings.md) · [Machine evidence](machine-findings.md).

## What changed and what disappeared

1. **Owned-prefix append.** Checked Bend proves exact structural append equations
   for an arbitrary closed list-like type. A bounded forwarding worker attempts
   an ownership-preserving runtime operation. It validates the entire left spine
   before mutation and attaches the already evaluated suffix without rebuilding
   the prefix. Shared/static inputs retain the original worker. Head values and
   wrappers remain intact; RFC count1 alone is insufficient without checking the
   resolved payload. Original evaluation order and stack safety are preserved.
2. **Primitive identities.** Exact `u32_to_nat` and `f32_bits` operands retain their
   existing representation through an ordinary typed assignment. Scratch result
   storage and conversion calls disappear. Other shapes retain their fallback.
3. **Verified sized runtime ABI.** Original structured constructor/take operations
   pass the unchanged verifier. Emission then consumes proved count/buffer facts
   for arities1–4. Construction also consumes proved constructor metadata; takes
   retain actual term tag/constructor/arity checks and all ownership behavior.

The machine audit confirms four fewer conditional branches per constructor helper
and two fewer per take helper, plus removed count-argument moves in callers.
For example, the primary ctor2 symbol falls75→62 instructions and278→226bytes;
take2 falls97→91 instructions and419→391bytes. These are static counts, not a
dynamic instruction count or a causal allocation of runtime improvement.

Diagnostic original RLE counts show32→26 constructor cells,42→36 consuming takes,
and54→45 allocator requests per invocation. Three append operations succeed,
visiting six cells. The independent map/append256 transfer shows770→514 for all
three counts, with one successful append visiting256 cells. Allocator requests
are not malloc calls. These counts were collected with the append diagnostic
variants; their instrumented clocks are never performance evidence.

## Broad program performance

Same original sources, inputs, independent output/count oracle and upstream
products; three rotated rounds, frozen repetition profile scaled4. Both candidate
and Phase124 products use the same aligned-assembler policy.

| Diagnostic | Phase124 in this run | Phase125 |
|---|---:|---:|
| Original44 geometric ratio to upstream |1.92031×|1.89221×|
| Family-weighted ratio |approximately1.979×|1.94826×|
| Mean positive log-slowdown |0.908321|0.895002|
| Programs above1.1× upstream |40|40|
| Programs above2× upstream |24|24|
| Sum of fixed-batch median times |26059ms|25648ms|
| Positive excess fixed-batch time |17940ms|17531ms|

Positive log-slowdown improves1.47%; exceptionally fast cases cannot cancel slow
cases in this diagnostic. Fixed-batch total improves1.58% and positive excess2.28%.
Family labels and workloads are frozen, not an estimate of real-world frequency.

RLE improves5.49% to5.47× upstream; expression32/128 improve5.0%/4.1%; lexer
variants improve roughly2.5–3.0%. The largest observed regression is1.17% on
scalar-region8192. Per-round geometric candidate/parent ratios are0.97994,
0.99322 and0.99506. Three rounds support a small screening result, not a precise
confidence interval for every one-percent difference.

The final independent transfer uses20000 repetitions, varying256 input words and
an ordered result hash checked independently. Its241→163ms result is32.37% less
than Phase124. An earlier source04 comparison was265→165ms, with identity-only
251ms; those are a separate run and producer. Neither transfer enters the44 score.

## Negative evidence and the ceiling

The source-level RLE repeat-into-tail ceiling is18.0% faster than Phase124, but it
changes bounded pure construction order. It is not the automatic transformation.
The automatic path still builds the first spine and rediscovers exclusive
ownership; removing the same number of cells does not imply equal total cost.

The raw-owner-only helper regressed5.84% and was rejected. Accepting exact RFC1
with dynamic payload checks was neutral, as was switching to a direct result ABI
alone. Typed source facts made the operation worthwhile. An initial source06 RLE
screen had substantial drift and a4.86% apparent regression. A four-round longer
matched ablation did not reproduce it: source06 was4.63% faster than source04 and
5.69% faster than Phase124. The final broad run also improves RLE.

A transfer fixture initially lacked an affine annotation and was refused by the
checker. The failed attempt and original source remain preserved; a separately
pinned corrected source passes. No correctness gate was weakened.

## Correctness and complexity

The final source passes32 pure admission/refusal predicates and21 exact ordinary
output lines covering retained whole/interior aliases, overlapping suffixes,
static-value eligibility, heap String payloads, empty input, a changed-equation
fallback and a4096-cell prefix. The original parent-derived graph is independently
verified for every emitted benchmark. Source fixtures alone do not prove a
specific physical RFC layout; the helper retains the relevant dynamic guards.

Compiler source grows52936→53219 physical lines (+283, including pure test
predicates). The three implementation modules total217 lines; additive C runtime
operations total65 lines. No new general IR, backend, search framework or installed
selection is introduced. Evidence/tooling growth is separate from compiler growth.
Generated QBE across45 programs shrinks39698679→39607034bytes (0.23%).

The paired whole-prepared hosted compiler screen is **0.99143× Phase124** across
RLE and lexer, approximately neutral: RLE0.94588×, lexer1.03917×. It includes
checking, lowering, verification and rendering, with deterministic output replay.
It is a small two-case cost screen, not a claim of faster native compilation or
compiler self-optimization. The additional sized-ABI step alone was1.01106× its
source04 parent in a separate paired screen.

## Native integration status

The selected source06 native campaign is in progress. It authenticates the exact
source, checked API, additive runtime and import authority, then runs hosted→N1→N2,
raw QBE reproduction, focused19 on both images and original45 correctness on N2.
The final status and separate native compiler timings will replace this paragraph
when the campaign completes. Until then Phase118 remains the qualified checkpoint.
Installed JS/native selections remain unchanged.

## What this teaches us

The strongest demonstrated capability is avoiding reconstruction of a substantial
owned prefix. Small RLE prefixes amortize the guard poorly; repeated checks were
also only a small part of the broad deficit. The next substantial experiment
should preserve private producer destinations across calls and local resumes,
eliminating construction or ownership rediscovery for whole computations.

The source equation certificate, typed representation identity, and verified call
contract are useful semantic interfaces to retain. Consolidate them when another
transformation needs them; do not introduce a universal IR to explain this result.
The [remaining opportunities](remaining-opportunities.md) distinguish the measured
ceiling from hypotheses needing new evidence. No causal recursive research
acceleration has been demonstrated.
