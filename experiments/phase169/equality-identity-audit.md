# Equality identity: current machine code and earlier causal evidence

**Do not treat a private borrowed-reader identity branch as a new optimization.**
It is absent in the actual Phase169 N2, but Phase131 already measured precisely
this idea and found a weak result. The separate owning-adapter branch remains
an unselected, previously positive ceiling; its whole-compiler evidence is
about three percent on three small requests, not twenty percent or a complete
self-build result. This review ran no target and changed no compiler code.

## What the current image actually does

The [native N2 profile](native-n2-profile-summary.md) attributes 467 of 5,484
accepted samples, 8.52%, to `$p118borrow.read.p88_string_eq_go`. The report has
no independent clean CPU denominator. This is physical leaf attribution, not
an absolute seconds estimate or a causal speedup forecast. Even removing all
work in that leaf would remove only its sampled share directly; a real branch
removes only a subset and adds a comparison. Related ownership work requires
separate attribution.

The actual N2 assembly confirms there is no full-Term identity branch:

- The private reader starts its loop at `.Lbb2147`, decodes the left and right
  constructor tags, then loads both character/tail pairs. It does not first
  compare the full left and right argument words in `%rsi` and `%rdx`.
- Its `cmpq %rax,%rcx` near the backedge compares the loaded, zero-extended
  character values. It is not a pointer/root comparison.
- Both `$direct.p88_string_eq` and `$direct.p88_string_eq_go` immediately call
  `p118_rt_borrow_scalar_safe`. Their only comparison is the guard result
  against zero. Success calls the private reader, then performs both original
  sinks; refusal calls the owning fallback. Neither has an identity arm.
- The maintained `p128bs_functions` emits exactly that guard/reader/two-sink
  adapter. The safe [source equality](../../selfhost/src/core/consuming-strings.bend)
  recursively compares contents; it has no native identity primitive.

The inspected image is `selfhost/build/phase169/native-n2/program`, 13,662,496
bytes, SHA256 `efed749ba181cf9f25f4a544d0505030aef819be31d29eb768fcaeb54e059db5`.
Its `program.s` is 62,383,507 bytes, SHA256
`087a573d4f5c44e5c114c975f040af0458ea72deaaaf1d460a2f89da083ea968`.
The complete assembly function blocks, from label through `.size`, are:

| Decoded function | Lines | SHA256 |
|---|---:|---|
| `$p118borrow.read.p88_string_eq_go` | 238 | `38b8db4174fa5438df26c4511ac7898221d5977062af339093f3a86a9a036bd7` |
| `$direct.p88_string_eq_go` | 46 | `51ddd1f393dbed071038a78e3002b908583eb45f86e1cb3baaf146d5572c8185` |
| `$direct.p88_string_eq` | 43 | `fad65d2a034e1c4f2d8ff27d976ebefc4ed20c8bcc36960b17db7725572ef628` |

The profile analysis is
`selfhost/build/phase169/native-n2-profile01/000-sample-canonical-compiler-n2-imports/analysis.json`,
SHA256 `f9adcc77c2ba2681e8abf29f4444bd1c56867cc6e91650a47b940aa2c2268fea`.

## What we already measured

The [Phase131 investigation](../../research/phase131/reader-identity.md) and
[experiment record](../phase131/P131-007-owning-identity-ceiling.md) explicitly
separate the following cases. Every number in this table is historical.

| Boundary | Historical evidence | Interpretation |
|---|---|---|
| Private borrowed reader, compiler-derived index queries | Identity+True on only 0.58–1.75% of reader steps | Negative first discriminator; public alias refusal can route equal roots elsewhere. |
| Same private reader, real `nq_uses` algorithm | 30.14–36% identity+True step coverage; median clean process 0.480943 → 0.479595 s, 0.28% lower | Coverage alone did not predict useful time saved. Not a compelling selected optimization. |
| Owning adapters, index queries | Skip the comparison but preserve both original root sinks; 0.429128 → 0.343274 s, 20.01% lower | Different ownership boundary and stronger proxy result. |
| Owning adapters, full compiler image | Two generated functions patched; 18 exact-output requests across three workloads; lexer 6.58% less, closures 2.21% less, Map 0.12% more; geometric reduction 2.93% | Useful unqualified ceiling. No selected Bend implementation or full self-build validation. |

The existing proof is for valid immutable Strings:
`p88_string_eq_go(x,x,same) = same`. The proposed machine branch compared
**complete 64-bit Term words**, never only heap locations, and required pending
True. Unequal words retained content comparison. Borrowing preserved the held
ancestor; the owning version consumed both roots in the original order. For an
RFC object with count two, the two releases still perform 2→1→0. Float equality,
user-defined equality and corrupted raw Terms are outside this contract.

The [existing checked-hook design](../../research/phase131/identity-hook.md)
already identifies a reusable production boundary: a source/dependency-bound
reflexivity fact admitted at `p128bs_functions`, emitted as ordinary verified
direct IR. A name recognizer is unsound because user definitions may reuse the
same name. No general diagonal-law inference pass is currently established.

## Cheapest next discriminator, only if prioritization changes

Do not acquire another full compiler solely to repeat the private-reader idea.
If the new N2 profile makes this worth reopening, first distinguish actual
removable traversal from cheap identities. A diagnostic derivative of the exact
current assembly can count calls, total iterations, the first identical
nonempty-root hit with pending True, and the subsequent iterations the original
execution still performs. Keep root and shared-suffix hits separate, and exclude
trivial empty/empty hits from the claimed removed traversal. A simple fraction
of identical iterations was already misleading in Phase131.

Count owning-adapter identity hits separately, before the unchanged alias guard.
That tests the previously positive boundary instead of silently conflating it
with the borrowed leaf. Root can run the count-only product on an existing real
compiler request; it must not be used for timing. The current N2 retains assembly
but not SSA, so an exact assembly derivative and unchanged runtime avoid a new
stage acquisition for this diagnostic. Such a derivative is explicitly
unqualified and never a release artifact.

Only after useful coverage should a clean branch-only derivative receive paired
timings and exact outputs. Preserve unequal-word/equal-content behavior, pending
False, retained aliases, and both releases. A checked implementation additionally
needs source/dependency admission and redefinition-refusal controls. Current
full-request gain is unknown; the historical roughly 3% owning-adapter result
is the appropriate prior. The private branch alone is a duplicate low-priority
idea, not evidence for reaching the remaining self-build target.
