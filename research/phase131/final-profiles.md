# Phase131: what remains hot in the final native compiler

The latest profiles support three targets: verifier name/index operations,
transient Base-decoder state, and QBE text construction. They do **not** support
prioritizing a broad `nc_bangs_names` cache. The 20.92% compilation gain and the
10.64% same-source N2/N1 gain are separately controlled timing results; profile
fractions below explain the remaining workload, not another measured speedup.

The measured executable is final **N2**, SHA `2fae3602…fd5dc`, compiled from source
`1bc5930…728f9`. N3 later passed independent qualification, but its different ELF
was not timed or sampled here. Exact evidence and counters are retained in
[profile-results.json](../../implementation/phase131/profile-results.json) and
[the native timing report](../../implementation/phase131/native-results.md).
The full local analysis is
`selfhost/build/phase131/final-profile-analysis01/report.json`.

## Measurement limits

| Request | Clean CPU seconds | Physical / context samples | Context-only wall overhead | Counter-enabled wall overhead |
|---|---:|---:|---:|---:|
| Lexer | 1.568 | 628 / 670 | 6.1% | 66.8% |
| Closures | 0.416 | 659 / 731 | 8.3% | 86.5% |
| Map | 1.912 | 807 / 835 | 8.0% | 68.4% |

All six pools exceed the 500-sample criterion. Accepted captures have zero
loss/overrun and adequate sampled-thread CPU coverage; none were rejected.
All complete outputs match pre-existing QBE oracles. Both native generations use
the same compact Base. The diagnostic image relinks the exact N2 program object
against the existing, authenticated diagnostic runtime; no runtime was recompiled.

Physical leaves and active dispatch owners describe overlapping work and must
not be added. Owners are the active dispatcher context, including work performed
by private callees; they are not inclusive source stacks or allocation origins.
Unknown samples remain in every denominator. Counter-enabled wall times are
clearly unsuitable as clean performance measurements. Three request profiles
also do not establish the distribution of a full compiler self-build.

## Work that disappeared

The baseline is Phase130 N1 from the earlier Phase131 profile block, with the same
runtime instrumentation and requests. These are absolute hook counts, not sample
fractions. Historical and current wall times were not interleaved, so the separate
controlled timing report remains authoritative for gain claims.

| Runtime work, millions | Lexer old → final | Closures old → final | Map old → final |
|---|---:|---:|---:|
| Dispatches | 22.106 → 15.164 | 6.341 → 5.582 | 31.544 → 18.736 |
| Allocation calls | 23.728 → 19.118 | 8.674 → 8.024 | 33.719 → 26.149 |
| Requested allocation words | 48.280 → 37.302 | 18.388 → 16.476 | 62.497 → 47.856 |
| Drop-hook calls | 24.764 → 21.329 | 3.438 → 2.913 | 38.357 → 22.628 |
| Register-copy words requested | 42.105 → 26.899 | 11.462 → 9.920 | 57.311 → 34.264 |

Requested register clearing remains zero. Frame pushes increase slightly in all
three requests, so this is not a uniform reduction in every runtime operation.
Private or inlined operations can bypass particular hooks; interpret each counter
according to its documented runtime entry point. Final allocation/free call counts
match within each request, which is useful evidence but not a general leak proof.

Reclamation is still substantial: `term_drop` is 11.8% / 9.9% / 12.6% of physical
samples, `span_fade` 7.9% / 4.1% / 6.6%, and `p125_rt_take2` 6.2% / 9.0% / 7.7%.
For lexer, estimated clean CPU under `term_drop` fell from 307ms to 185ms; the
remaining 185ms matters even though its fraction is lower.

Every sampled libc copy PC covered by the authenticated unwind rules recovers
`p111_set_regs` as its physical caller. These samples occupy 4.82% / 8.25% / 6.65%
of **all** physical samples. This identifies register transport, not an arbitrary
`memcpy` bottleneck or a logical caller stack. Other samples are explicitly
unrecovered by this limited libc-only unwind table.

## 1. Verifier operations: improve representation, preserve authority

All `p111v_*` active owners account for **23.81% / 5.40% / 14.98%** of diagnostic
samples. Lexer `p111v_get` alone is 9.72%; its remaining verifier names include
`p111v_name_chars` 3.33%, intersection buckets 2.43%, and value checking 2.02%.
The original physical image independently attributes 6.38% of lexer samples,
approximately 100ms clean CPU, to the borrowed `index_hash` worker.

The actual selected source contains:

```bend
def p111v_get(+tree: KDef, +name: String) -> KDef:
  index_find(tree,name,index_hash(name,2166136261),32)
```

`p111v_put` independently hashes the name again and builds a wide `KDef` carrying
kind/width/capacity plus unused term fields. `p111v_name_chars` recursively checks
the same character representation. Its lexer context requests 2,483,053 register
copy words, 9.23% of that counter. The independent verifier is now a meaningful
compiler workload in its own right.

Start with a small verified-name or prehashed lookup experiment inside one
verifier operation, and a compact verifier-specific entry instead of `KDef`.
Avoid merely moving a hash lookup into a second interning map. A larger version
would number validated IR identifiers once and use compact entries thereafter;
that requires a clear name/ID boundary and collision/error preservation. The final
verifier must still independently reject invalid names, missing references,
duplicates, bad widths and invalid control flow. Optimizer claims cannot replace
its checks.

The cheapest falsification is an extracted verifier request from the actual
lexer IR, with exact success/refusal controls and complete QBE equality. Count
hash/character work and allocations before building another compiler image.
A source-level fast path that leaves the same hashes and wide entries has not
addressed the observed problem.

## 2. Base-decoder state: a fixed cost on every request

The explicit `p88_*`/`p130m*` owner set occupies **14.17% / 48.68% / 10.59%**.
These buckets expose their exact names in the JSON; they are not a claim that all
Base work is captured. `p88_number` requests exactly **4,536,966 allocation words**
in each request, `p130m_word` 1,624,780, `p88_field` 2,066,630, and
`p88_fields_finish` 1,019,855. These constant counts strongly distinguish fixed
carrier work from source-size-dependent optimization.

The source shows the same decoded number wrapped and unwrapped through
`P88Number{P88Cursor{...},n}`, `P88State{...}`, `P88Word{n}` and `P88Step{...}`.
`p88_field` calls `p88_number`, then consumes the returned step. The current
word-pair representation solved decimal parsing; temporary products, scheduler
boundaries and state reconstruction still remain.

A bounded next experiment is a fused checked decoder of a field/record that keeps
cursor, mode and scalar value local until the state genuinely escapes. Preserve
truncation, malformed words, role mismatches, trailing data, legacy fallback and
source/runtime identity. Compare all decoded roots and downstream QBE against the
existing independent carrier and source oracles. This can test allocation removal
without introducing a new persistent cache.

The more ambitious version is a versioned, relocatable immutable Base image that
avoids rebuilding the same object graph on every fresh process. That is a separate
runtime/ownership project: pointer validity, mutation, sharing, identity and
invalidation are real obligations. A warm daemon is another useful workflow, but
cannot silently replace this frozen cold-request metric.

## 3. Emission: avoid transient strings before trying a new backend

`String.append` accounts for 4.60% / 1.85% / 6.16% of active-owner samples and
**8,015,180 / 907,149 / 11,751,661** requested allocation words. On Map it owns
24.6% of requested allocation words. `p111q_memory` adds 3,341,699 words and
`p111q_body_text` 2,535,578 under their respective contexts. The emitter builds
instruction lines from chained `++`, then joins per-function chunks.

The existing `nt_text_finish` is already linear in its input characters: it
prepends each new chunk to an existing suffix. Do not misdiagnose it as repeatedly
copying the growing suffix. There is still construction and copying of intermediate
instruction strings and a final function string.

Test one memory-instruction formatter using retained token/chunk pieces or an
owned destination, with exact emitted-byte equality. Then transfer to function
headers, calls and an unrelated formatting workload. An output sink can eventually
avoid whole-function materialization, but must preserve output order and refusal
behavior; it should not publish partial invalid output before admission. Allocation
reduction alone is not a runtime gain, so qualify both clean timing and code growth.

## Lower priorities and realistic next experiments

`nc_bangs_names` has **138 / 48 / 219** actual direct dispatch entries; the whole
`nc_bangs_*` active-owner set is only **0.12% / 0.11% / 0.41%**. Private worker calls
and repeated equal keys are not counted, but these samples do not justify a large
bang-analysis cache. Existing use-query owners are also below 0.7% after this phase.

| Next hypothesis | Plausible three-request gain, not measured | Small decisive experiment | Approximate implementation + focused evaluation |
|---|---:|---|---:|
| Compact verifier entries and reused name facts | 4–9% | Actual lexer verification slice; exact refusals and output | 1–2h |
| Fuse decoder field/state wrappers | 5–12%, especially short requests | One fixed carrier decode with malformed controls; count words and clean CPU | 1–2h |
| Emit chunks without intermediate instruction strings | 3–8% | Memory formatter plus independent formatter transfer; byte identity | 45–90min |
| Preserve more private scalar/product calls across continuations | 2–5% alone | One measured decoder/verifier caller with lower register-copy count | 1–2h |
| Immutable Base image or numbered IR names | Potentially larger; unmeasured | Prove one representation boundary before changing the complete pipeline | 3–6h+ |

These estimates are hypotheses based on sampled work, not sums of allocation
fractions. They overlap and must not be multiplied as independent promised gains.
The measured verifier and decoder shares suggest meaningful headroom; they do not
prove that removing half of those costs is practical. None alone establishes a
route from 1.44× to parity. The most valuable next action is a cheap source-level
ceiling on one of the first two, then promote only a transformation that removes
measured work and preserves the independent verifier and cold-request contract.

## Full-source refresh changes the self-hosting priority

A later, single sample-only full compiler-source execution is now available;
[its report](../../implementation/phase131/full-profile-results.md) and
[retained measurements](../../implementation/phase131/full-profile-results.json)
keep it separate from the three short requests. It has 11,254 zero-loss samples
at 32ms, exact complete-QBE output, no paired clean baseline and no new gain ratio.

For the full self-build, `term_drop` plus `span_fade` occupy **29.38%** of physical
samples, the borrowed `p88_string_eq_go` worker **10.02%**, and borrowed
`index_hash` only **1.73%**. Equality is especially prominent in the approximate
90–120s CPU window (33.0%), together with borrowed `has_name` (6.3%). Do not mistake
`p88_string_eq_go` for Base-only work: `has_name` uses it for membership and
`p98_tag_eq_read` uses it for `KTerm` tags. Without active dispatch contexts this
capture cannot distinguish their respective contributions.

This adds a second optimization track. Cold-request latency still motivates the
verifier and decoder experiments above. Full compiler acquisition instead
motivates a source-grounded membership/comparison experiment, followed by removal
of a measured intermediate graph or redundant ownership transition. A broad
interned-tag or graph-layout rewrite is premature until the actual hot callers
are pinned down. The current physical profile cannot attribute the 29.38%
reclamation share to a specific producing computation or turn that whole share
into an achievable gain estimate.

The strongest cheap next experiment is to retain the actual hot comparison
workload's input cardinalities and outputs, compare a keyed-set/known-tag variant
with the current computation, and demonstrate removal of comparisons **and**
intermediate ownership work. Use existing source laws, independent oracles and
full-source identity gates. If caller attribution cannot be resolved offline, one
future full-source context-only run is justified before investing in that rewrite;
the coordinator has scheduled one separate full-source context-only capture,
with counters disabled, to resolve this uncertainty. Its evidence must remain
separate from the original physical capture.

## The full-source context follow-up resolves a concrete next target

The subsequently completed [context-only capture](../../implementation/phase131/full-context-results.md)
has 11,852 zero-loss samples, counters disabled and exact whole-QBE output. The
largest owner is **`nc_ctor_owned` (7.48%)**, followed by `lookup` (5.43%), `f_find`
(5.20%) and `p111v_get` (4.43%). Within drop/span physical leaves, `nc_ctor_owned`
accounts for 13.72%, or 3.97% of all samples. Its source scans all book definitions
and performs nested constructor lookup for each queried name.

This improves the next-experiment choice: test borrowing and a once-per-immutable-
checked-book constructor-ownership summary, retaining the original function as
oracle and preserving first-match, missing, duplicate and raw-book behavior.
Do not build the summary per query or remove independent validation. Its observed
context share supplies a bounded ceiling; a half-cost reduction would be about
3.7% of this diagnostic request, not a demonstrated gain.

The equality matrix also supports investigating repeated membership/lookup:
`has_name`, `p88_string_eq`, `f_find`, `nb_contains`, `nc_ctor_owned` and `lookup`
own 23.05%, 14.63%, 9.57%, 8.60%, 7.71% and 6.12% of borrowed equality samples.
Private callees retain the outer dispatch context, so this is not a complete
source-call graph. Nevertheless it is stronger evidence for eliminating searches
than for a speculative global symbolic-tag rewrite. Preserve this distinction in
the next native-development/incremental-build design.
