# Phase130: contracts for Base preparation and scalar queries

Independent source review at `bf833905123d3cc0724ea921c2523a1290140dfb`.
No target, compiler build or proof kernel was run for this document. Production
and installed selections are unchanged. The baseline is the exact selected
[Phase128 source02](../../implementation/phase128/candidate.json), SHA256
`6bd9de05e251180280a6761fa46be30dc2a22164cdb35c9ca48fd710911d0f4d`.

These contracts qualify bounded experiments. They do not claim that finite
predicates prove whole-compiler correctness, that a routing stamp authenticates
a cache, or that source-level equality proves native ownership preservation.

## 1. Preserve the measured boundary

[Phase129](../../implementation/phase129/README.md) establishes fixed decoder
work on the current N1: all three requests execute the same 1,087,899 decimal
entry segments. It also exposes scalar ordering in lookup-heavy workloads.
Context samples, physical reclamation and register-copy samples overlap; their
percentages cannot be added into a gain prediction.

Keep one serial target lane, exact request inputs, consumer image, runtime,
Base/carrier and frozen output oracles. Record separately:

- Decoder/materialization time, complete preparation time and request time.
- Cold process wall time, including reading a changed carrier representation.
- Compiler acquisition and qualification cost.
- Generated-program runtime, which is a separate objective.

A warm prepared object reused across requests changes the service policy. Do not
present that clock as improved cold compilation. A Base-only cleanup should emit
byte-identical QBE for identical requests. A genuine scalar code-generation
optimization may change QBE, and must instead retain independent semantic and
performance gates.

## 2. Actual Base preparation trust boundary

The current [decoder](../../selfhost/tools/performance/phase88/base/decoder.bend)
reconstructs ordinary typed Bend values into `P88Products`: the complete book,
fresh-ID state, frontend-ready state and checked prepared world. Its arrays are
affine temporary state; they are not a reusable cross-request mutable cache.
Selected `p88_cache_prepare` constructs the original located `FSource` and
passes decoded products through unchanged `p86_prepare_states`.

The [serializer](../../selfhost/tools/performance/phase88/base/carrier.mjs)
authenticates an existing checked producer artifact; it does not run a second
compiler. Relevant bindings include:

- Exact producer API and source cache identity, with `validatedBy=check_book`.
- Exact Base bytes **and path**, source range, term ABI1 and span ABI3.
- Frame/version, prepared-world version3, and versions/producers of checked,
  fresh and frontend-ready states.
- Exact complete serialized payload, record/string schema and root order.
- Consumer implementation and qualification that admit this precise producer
  format and semantic world.

The [historical authentication controls](../../selfhost/tools/performance/phase88/auth-controls.py)
already reject a self-declared changed payload hash and same-byte Base at a
different path. They illustrate required behavior; their old fixed consumer
allowlist must not be mistaken for Phase130 admission. Current qualification
binds its own exact source/API/runtime/evidence through the
[Phase128 native gates](../../selfhost/tools/performance/phase128/native/qualify.py).

`p88_decode_admitted` compares a stamp, but a caller supplying both a payload and
a matching self-chosen stamp has not established trust. An external trusted
receipt must bind full bytes, producer and consumer. A static seed also needs
that provenance: type-correct constructors with `ready=True` do not prove that
the represented book was checked.

Invalidation must cover changed Base, path/span convention, compiler-world
representation, normalization/checker assumptions, producer versions and
supported consumer. Reusing an old producer across a compiler edit is allowed
only under an explicit compatibility/qualification relation, not merely because
the new compiler can parse the record fields.

## 3. Narrow compact-carrier discriminator

The preparation agent proposes two valid Unicode scalars per U32, containing
the low and high16-bit halves, each offset by U+10000. Replace the private
numeric reader while preserving downstream record, reference, span, readiness
and materialization logic. A Bend transcoder derives the candidate from the
authenticated old carrier; ordinary constructor reconstruction remains in Bend.
This is a proposed format experiment, not yet an audited native implementation.

The initial [word-pair implementation](../../selfhost/tools/performance/phase130/base/word-pair.bend)
and [isolated override](../../selfhost/tools/performance/phase130/base/word-pair-override.bend)
were subsequently inspected during this review. Both scalar ranges are checked
before reconstruction; invalid input resets to the original empty/false cursor
convention. No numeric source blocker was found. The initial
[controls](../../selfhost/tools/performance/phase130/base/controls.bend) should
also cover low-half overflow, high-half underflow and an empty successful suffix,
alongside their existing bounds and nonempty-suffix cases. This observation is
source review only; it does not report source checking or execution.

Required numeric contract:

```text
lo, hi in [0,65535]
encode(word) = [Chr(65536 + lo), Chr(65536 + hi)]
decode(encode(word) ++ suffix) = (word, suffix, success)
word = lo + 65536 * hi
```

Both encoded scalars lie in U+10000..U+1FFFF, excluding surrogates. Bounds must
be checked before subtracting/multiplying. The maximum reconstructed value is
4294967295, so the admitted arithmetic does not wrap. Exactly two scalars are
consumed; truncation, out-of-range scalar and invalid incoming cursor return the
documented failure state. Preserve the old `p88_u32` failure cursor convention
if the rest of the decoder relies on it.

Three length domains must stay distinct:

1. Carrier string lengths count Unicode scalars, as the original decoder does.
2. Base source spans use the existing `p86_width`/UTF16-unit convention.
3. Host file/resource limits count UTF8 bytes.

Two supplementary characters use eight UTF8 bytes per number. The carrier can
grow in bytes while shrinking in Bend String nodes and arithmetic. Measure byte
size, node count, file-read/UTF8 decoding time and complete preparation; fewer
decimal loops alone do not establish a useful gain.

Use a distinct authenticated format/entry and receipt. If the old stamp text is
retained inside a transcoded carrier, the outer format identity must distinguish
it and bind the exact consumer; otherwise derive a new stamp and expected value.
Never silently send compact bytes through the old public/default decimal route.
Reject an invalid selected cache explicitly; do not hide failure with a slow
fresh-Base fallback inside the benchmark.

Keep original limits: five typed roots, at most65,536 records,4,096 strings and
1Mi scalar values per string, strictly backward node references, valid field
roles, canonical Bool values, source spans and trailing-data rejection. A new
byte limit, if needed for the new encoding, is an explicit format/resource
change rather than an unnoticed relaxation.

For a later static seed, generate ordinary typed constructors from the exact
checked artifact. Do not emit raw native Terms, offsets, closure pointers or
forged checked-state flags. Preserve the DAG's needed shared nodes; duplicating
the whole graph can make initialization/destruction worse. A large nested
constant can also move work into compiler normalization or native stack use.

## 4. Cheapest decisive Base gates

Run these in increasing cost, stopping when the hypothesis fails:

1. **Data and source binding.** Pin old/new carriers, transcoder, original and
   candidate source, producer receipt and format versions. A reversible source
   splice should identify exactly changed declarations. Verify bounds and sizes
   before any target invocation.
2. **Numeric/cursor controls.** Cover0,1,65535,65536,U32max, nonempty suffix,
   truncation at each half, scalar just outside each bound, invalid incoming
   cursor and trailing bytes. A valid round trip is insufficient without
   malformed-input controls.
3. **Whole preparation equality.** Compare every field of candidate
   `P88Products`/`P86Preparation` with original decoding and fresh
   `p86_prepare`. Reuse the complete-value method in
   [compare-products.mjs](../../selfhost/tools/performance/phase88/base/compare-products.mjs).
   Compare complete definitions, duplicates/order, metadata, checked/fresh state,
   diagnostic values and every world field. Root counts, selected getters and
   hashes of a few observations are insufficient.
4. **Sharing checks.** Preserve `world.prefix` as the book and the world's state
   as the corresponding checked state; compare graph relationships separately
   from structural equality. The existing JS comparator checks value structure
   and selected aliases, not an isomorphism of every graph node. Native controls
   must retain/reuse/consume roots successfully; JS identity alone does not
   establish native ownership.
5. **Complete request equality.** Existing short requests must produce exact
   old QBE, including stable names, constructor IDs and complete diagnostics.
   One invalid user source should follow the same ordinary error route. A
   changed invalid-carrier error should be explicitly scoped to the new format.
6. **Clean cost test.** Compare decoder-only and full cold requests with paired
   schedules and independent outputs. Do not include diagnostic comparisons
   inside the performance interval. A worthwhile small result warrants native
   acquisition; it does not itself grant N1/N2 qualification.

A source-only API test may expose behavior but cannot establish native speed or
bounded native stack. The compact numeric reader is constant-depth; the retained
record/string traversals and any transcoder or generated seed still need their
existing explicit/stack-safe execution behavior. Do not replace them with an
input-sized chain of ordinary native calls.

## 5. Scalar String comparison contract

Pinned [Base](../../selfhost/.bootstrap/upstream-phase66/bend2/base.bend#L1893)
defines `String.cmp(a,b)` returning `((a,b),comparison)`, reconstructing preserved
inputs. `String.order` immediately selects only the comparison with `Pair.snd`.
The proposed [scalar ceiling](../../selfhost/tools/performance/phase130/scalar/order.bend)
uses a sticky LT/GT accumulator and descends only while equal. Source inspection
finds the expected codepoint-order behavior. It remains a source-level ceiling,
not evidence that a general projection optimization is implemented or profitable.

Its source-value contract is:

```text
for every finite String a,b:
  p130s_order(a,b) = Pair.snd(String & String, Cmp, String.cmp(a,b))
```

A useful stronger induction includes arbitrary initial comparison:
the scalar worker returns the initial LT/GT unchanged, and computes the original
ordering only for EQ. This prevents proving only the common equal-prefix case.
Comparisons use full codepoint values, not locale order, UTF16 code units or
Unicode normalization.

For compiler integration, require all of the following:

- Exact producer/consumer projection: discarded product fields are not observed
  or retained elsewhere. Preserve evaluation of demanded computations and
  failures; do not generalize by deleting arbitrary discarded effectful fields.
- Independently established nonowning scalar result, using the exact nominal
  type and constructor layout. Here Cmp is a finite nullary enum; an arbitrary
  similarly named/user-defined type is not automatically equivalent.
- Borrowed readers run while their original roots/ancestors remain live. Their
  helpers have admitted read-only summaries; borrowed child pointers never
  become owned escaping results.
- Root ownership after return is identical. Current scalar adapters sink their
  consumed roots once; copying a borrowed word is not an ownership transfer.
- Existing `p118_rt_borrow_scalar_safe` guard remains conservative: unique
  nontrivial roots and identical nontrivial RFC cells fall back. Two aliased
  adapter-owned references do not imply an external owner survives both sinks.
- Preserve original fallback, public ABI, finite helper dependency DAG and the
  final projected verifier. Unknown calls/effects/representation forms refuse
  optimization rather than inheriting an unproved summary.
- Tail cursor progress remains a local loop. Do not turn a stack-safe recursive
  computation into an input-depth native call chain.

The selected guard is in
[runtime.c](../../selfhost/build/phase128/runtime-borrow01/runtime.c#L4751).
The [borrowed-query guide](../../docs/self_hosted/borrowed-native-queries.md)
and existing Phase128 ownership audits retain the broader ABI premises.

The borrowing agent's bounded integration proposal is to seed a helper summary
from an already-admitted **product observer** such as String.cmp. The call executes
its existing scalar reader, then substitutes the original held argument origins
and scalar result into the observer's virtual constructor wrapper. Ordinary
Pair.snd evaluation can project that virtual wrapper without allocating it.
This composes existing capabilities rather than recognizing String.order by name.

That proposal additionally requires the exact admitted Ctr/Var wrapper tree,
existing root/result-use checks, substitution by binding ID, and a result ID
distinct from parameter IDs and the new call marker. The helper summary must
refer to an actually emitted/verified reader with matching parameters and one
scalar result, not merely a successful schema. Borrowed root fields stay the
original held OA origins. The reader call remains eager even if a later
projection discards its result; virtual construction must introduce no effects.
No new recursive helper cycle or materialized owned escape is admitted. These
are review obligations for the eventual source, not a completed implementation
or proof of that extension.

## 6. Scalar falsifiers and transfer

Use complete per-pair Cmp results for a small semantic matrix, retaining digest
folds only for efficient timed loops. Include empty/empty, each empty/nonempty
direction, equal strings, strict prefixes, early/late mismatches, NUL, non-ASCII,
supplementary scalars and U+E000 versus U+10000. That last pair distinguishes
codepoint order from UTF16-unit ordering.

Exercise unique dynamic strings, retained shared roots, identical roots and
distinct roots with a shared suffix. Observe and finally consume retained
strings after comparison. Include a long equal/shared prefix under bounded
resources to reveal accidental native recursion; size128 alone is a weak stack
control. Static literals alone cannot exercise the ownership transitions.

The [initial workload](../../selfhost/tools/performance/phase130/scalar/workload.bend)
already includes many value, Unicode, sharing and alias cases. Its timed digest
is a useful consumed-output check, not a universal theorem or full-output proof.
Require an independent codepoint oracle and inspect whether the hot caller
actually reaches the scalar reader. Phase128 already showed that admitting a
reader without caller composition need not improve runtime.

Before a general optimizer promotion, transfer to an unrelated list/tree or
compiler query with a comparable scalar-consumer boundary. Count eliminated
product construction, reconstruction, takes/sinks and scheduler transitions,
then confirm clean runtime improves. Retain cases that do not benefit or regress.
Full native qualification follows a demonstrated useful bounded result, not
every early source experiment.

## 7. Small theorem opportunities, without a proof campaign

Two contracts are useful and narrow enough to consider later:

1. **Scalar ordering equality.** Prove the actual safe ceiling worker equals
   the exact Base projection for all finite input strings, with the accumulator
   invariant above. Freeze helper/reference bodies and authenticate the emitted
   safe dependency closure. A wrong mismatch direction or truncated codepoint
   mutant should first pass helper checking, then fail the unchanged law.
2. **Numeric codec left inverse with suffix preservation.** Prove the actual
   compact decoder returns every encoded U32 with the untouched suffix, together
   with its validity predicate. A model using unbounded Nat alone does not
   establish U32 arithmetic safety; connect the bounded representation or state
   that bridge explicitly. Swapped halves and missing upper-bound checks are
   useful negative controls.

These are mathematical value contracts only when complete proof bodies pass
independent BendTT checking. They do not prove the native backend, ownership,
authentication, ABI or performance. Historical laws or finite `:pass` predicates
cannot be relabelled as a new theorem. Do not launch a kernel campaign until one
bounded experiment makes the contract worth maintaining.
