# Native compiler request cost: source audit

This is a source audit of the Phase86 native B1 plus an isolated candidate patch,
not a measured optimization. This lane executed no compiler, generated program,
or benchmark. Root supplied the native profiles discussed below. Source
inspection narrows the repeat-slowdown mechanisms but does not yet identify its
cause conclusively. Production and upstream sources remain unchanged.

## Evidence and scope

The source is the current Bend compiler, emitted to C by pinned upstream
`059266225b77c8ca256ac6b25ee5c21449bab151` and built with Clang22.1.4 `-O2`.
This is a native-hosted **B1 compiler**, not the installed JS-hosted B2 or a
measurement of the user programs it produces.

The Phase86 [follow-up receipt](../../selfhost/build/phase86/followup01/report.json)
contains one process with five identical requests per source:

| Source | Native first → fifth | Sibling JS first → fifth |
| --- | ---: | ---: |
| Small | 85 → 90 ms | 223 → 84 ms |
| Functions65 | 376 → 406 ms | 593 → 239 ms |
| Numeric closed | 240 → 310 ms | 395 → 144 ms |
| Lexer original | 5,314 → 10,791 ms | 1,057 → 476 ms |

Lexer intermediate requests are 6,549, 8,089 and 9,659 ms. All five return the
same exact C and `consumed_chars=419027`. Its process peaks at 42,471,424 RSS
bytes, runs on CPU3 with `--threads 1 --gpu off`, and exits successfully. RSS is
a whole-process peak, not a per-request live-object measurement. The sibling JS
uses the documented primitive String equality compatibility derivative; normal
B2 is separate. Map fails the native reference-counting guard and is not omitted
from an aggregate claimed to represent broad native performance.

Pins used for this audit:

| Artifact | SHA256 |
| --- | --- |
| `phase86/acquire08/compiler.c` | `af8a54a687072126e361607749b57bad9ddd0638e41a725c178b1eff35ea968a` |
| `phase86/compiler-final-o2` | `1d45119d6cfa95af32308ddbf2e8646d2039bab94e5424243ba93aeb563a9bf1` |
| `phase86/entry.bend` source | `3e6707ab55094c5ef7140652f43c25483833de4860921c91e97b606afa7eba4f` |
| Pinned upstream `comp.ts` | `2b13224ba09a9e39e37cccf06e449c1bdafe5e03a81641654f7d0e455507629c` |
| `back/native/text.bend` | `31c1ff5973df46d17ad395070fbefa1d2dc58398b3d12af80c62ed6c5548ff9d` |
| `back/native/emit.bend` | `73aba2f0b1eb035bd8a58075deea68ca682fd0bc36957f95ab15ec3985a98dc6` |

The first two paths are relative to `selfhost/build/`; entry is under
`selfhost/tools/performance/`; compiler modules are under `selfhost/src/`.

## What the actual runtime does

Pinned `comp.ts:3720–3843` allocates from per-lane, per-size-class HOT LIFO chains,
then COLD generations, then a global generation bank, then fresh pages. A pop
reads one head; it does not scan a progressively longer free list. CPU
`KEEP_WORDS=32768` and fresh quantum size are distinct. Freed objects are
recycled but not compacted. A low resident footprint therefore does not establish
good locality. A long chain can touch scattered cache lines within the same
40 MiB footprint.

`comp.ts:3879–4054` represents sharing with one redirect cell containing a
24-bit reference count and object location. `term_keep` bumps an existing
redirect; it does **not** wrap it again. `term_peek` follows one redirect.
`ctr_take` can release/reuse the node when the count is one. Otherwise it
increments shared children through `span_fade` and drops the parent reference.
`term_drop` walks objects whose last reference is released; this is not a tracing
collector that periodically scans all resident memory.

Counts above one do not make lookup cost proportional to the count. Prepared
Base sharing can change whether nodes are reusable, but a monotonic slowdown
needs changing ownership, retained objects, layout, or external conditions.
“Reference counts get larger on every request” is an unverified hypothesis, not
an explanation supplied by immutable reuse alone.

Native String is a linked `SCon` chain. Actual generated
`compiler.c:663801`, `FID_STRING_APPEND`, traverses the entire left operand,
records its characters in continuations, and frees reclaimable cells. Its return
continuation allocates an `SCon` and seals its tail for every character. This
particular generated append does not directly reuse a saved constructor cell.
Even an affine left operand pays traversal and reconstruction; shared strings add
reference-count traffic and inhibit reclaiming their cells.

## Repeated entry and output lifetime

`p86_requests` retains one immutable prepared Base, runtime parts and source text.
Each request loads/checks/emits again. The timer includes complete traversal of
returned source/error/verdict strings. It excludes reading the initial inputs,
Base preparation, canonical runtime-part transport and writing each returned C.
`IO.now` uses `CLOCK_MONOTONIC`, not accumulated process CPU time.

The generated entry makes this ownership explicit:

- `FID_P86_REQUESTS_C25071` (`compiler.c:659947`) retains the ten non-scalar seed
  fields and input/text before passing a copy into `p86_plan`.
- `FID_P86_REQUESTS_C25075` (`660418`) keeps result fields once for the timed
  `p86_consumed` traversal and once for subsequent output handling.
- `FID_P86_REQUESTS_C25100` (`662770`) forwards only the seed/runtime/path/count
  arguments to the next request. It carries no previous result string or list of
  results. The final verdict closure is dropped by `kc` on repeat iterations.

Upstream `effs/file_write.c` calls `io_cstr`, which consumes the String via
`ctr_take`, and frees the malloc buffer in `file_write_pack`. The IO loop
(`comp.ts:5850` onward) replaces the current continuation/item; the source does
not intentionally queue previous request results until process exit.

This rejects an obvious source-level result accumulation. It does not prove the
entire generated ownership graph is correct: counts and live nodes still need a
runtime observation. The write step can change the free-list order seen by the
next request even though its own elapsed time lies outside the request timer.
Changing the output destination alone would not remove String conversion or
deallocation, so it is a poor discriminator for this memory-layout effect.

## Ranked explanations and discriminators

| Hypothesis | Why it fits / limitation | Cheapest decisive observation |
| --- | --- | --- |
| Recycled small-node layout progressively worsens cache/TLB locality | Every parser/IR/string operation shares allocator classes; output teardown returns many string cells. First request can use more contiguous fresh pages. Constant RSS is compatible. No direct counter evidence yet. | Profile one existing five-request process by request interval. Similar instruction counts but rising cycles and cache/TLB misses support this. Sampled native stacks alone identify where time grows, not why. |
| Ownership or continuation retention changes reuse | Prepared roots are explicitly retained; unexpected aliases could suppress `ctr_take` reuse without huge RSS growth. No accumulated result is visible in source or the repeat continuation. | At a few `IO.now` boundaries inspect prepared root redirect counts, heap bump and generation counts. Increasing live counts or allocation work across requests support it; stable counts weaken it. Avoid breakpoints on every `term_keep`. |
| Identical work suffers frequency/scheduling changes | Timings are monotonic wall time on one pinned CPU; low RSS does not exclude contention or frequency effects. Source-specific growth and an independent ~5.3 s first request make this insufficient as the sole explanation. | Capture task CPU time, cycles/instructions and scheduling/frequency context alongside the same profile. Compare first requests in fresh processes. |
| Cumulative allocator search, nested redirects, delayed global GC | These mechanisms do not match this runtime's source. | Do not optimize them without contrary evidence from the actual binary. |

Start with the existing binary and symbols. A profiler or counters segmented at
the existing request markers avoids the ~259 s image acquisition/build cycle.
If hardware counters are unavailable, compare first/last sampled stacks and CPU
time, then use a small number of allocator/root snapshots. Before patching the
runtime, repeat two fresh one-request Lexer processes: roughly 17 s of known
Base+request work total, excluding host overhead. This tests whether the growth
is process-history dependent; it does not distinguish locality from ownership.

Do not treat removing the repeat growth as native parity. Returning the fifth
Lexer request to its first-call cost would still leave about 5.3 s versus the
sibling JS's 0.476 s fifth call. The expensive baseline needs separate work.

## General compiler opportunities, pending attribution

The strongest source-level target is an append-friendly text builder, applied to
general compiler helpers rather than Lexer-specific handling:

| Helper | Current native work | General alternative |
| --- | --- | --- |
| `text.bend:89 nt_lines_go` | Appends each character to a growing prefix: quadratic character traversal/reconstruction | Reverse character/chunk accumulation followed by one linear assembly; preserve exact newline indentation |
| `text.bend:8 nt_join_go` | Re-copies earlier joined text on each element | One-pass chunk/list construction with linear flattening |
| `emit.bend:120 ne_segments_go` | Re-copies all earlier emitted segments | Collect segments and flatten once |
| `text.bend:70 nt_replace_step` | Re-copies the growing scanned prefix before replacement | Reverse prefix or chunk accumulation, retaining first-match semantics |

Not all concatenation is bad: `nt_clean` emits a bounded one-character prefix
before its recursive suffix; the frontend word scanner already uses reverse
accumulation. The old native runtime-template scanner was another quadratic
builder, but the active entry already transports canonical prepared chunks.
Its measured 16.6 s removal must not be counted again as request headroom.

For the builders, first attribute native samples and establish character counts
or size scaling on bounded inputs. A general helper microcase at size N and 2N,
with exact output checks, can test the expected quadratic cost cheaply before a
whole-compiler rebuild. Use both native and JS siblings: linked-string-friendly
rewrites can trade away JS engine optimizations. A one-pass builder has a strong
asymptotic argument, but its whole-request gain is bounded by its measured share;
no percentage or parity forecast is justified by this audit alone.

An eventual native packed-string/buffer representation could eliminate much of
this per-character allocation and ownership traffic. That is a larger runtime
and compiler design change, with Unicode, ownership and target-parallelism
requirements. First test linear general builders in Bend; preserve compiler
semantics and the installed JS host while diagnosing the native prototype.

## Native profiles obtained by root during this audit

The [five-request native Lexer profile](../../selfhost/build/phase87/lexer-five.analysis.json)
has 10,983 samples, zero overruns at a 4,000 μs period, and 99.99995% sampled-thread
coverage of 43.935 s process CPU. Leaf samples are:

| Function | Sample share |
| --- | ---: |
| `WL_FID_STRING_APPEND` | 44.60% |
| `WL_FID_STRING_APPEND_K25183` | 22.79% |
| `rfc_wrap` | 19.38% |
| `term_drop` | 6.63% |
| `span_fade` | 2.13% |

Append traversal and reconstruction therefore occupy 67.39% of samples. These
are disjoint leaf buckets; the ownership functions are additional leaf costs,
but attributing all of them to append would require caller information. This is
strong evidence for testing general String builders, not proof of which caller
accounts for each sample or why later requests slow down.

The [one-request Lexer profile](../../selfhost/build/phase87/lexer-one.analysis.json)
has 2,119 samples, 8.478 s process CPU and 39.31% append/return samples. Its
requested 1,000 μs timer overruns 6,356 times; use the zero-overrun five-request
capture preferentially. Both profiles include Base preparation and output IO.
The [Small profile](../../selfhost/build/phase87/small-one.analysis.json) spends
3.207 s CPU, predominantly preparing Base; `term_drop` is 46.69%, `span_fade`
15.86%, and append is not a top bucket. The differing fixed-cost mixture means
the two Lexer percentages are not a measured per-request growth curve. It also
suggests that fixing emission builders will not remove the roughly 3 s Base
preparation bill.

## Frozen candidate and correctness argument

[linear-builders.patch](linear-builders.patch), SHA256
`5bec499f8b6aeb6a9e56af8c66cb54a3f3e7986fec99e1d381dc8507fbf7c707`, passes
`git apply --check` against the audited production sources. It changes only
`text.bend` and `emit.bend` inside the eventual isolated candidate:

1. `nt_text_finish([cN,…,c1], suffix)` yields
   `c1 ++ … ++ cN ++ suffix`. Each chunk is the left operand of append exactly
   once. This tail-recursive helper is shared by joins and segment assembly.
2. `nt_join_chunks` records each selected separator followed by its element in
   reverse output order. Initial `first=False` retains the leading separator;
   an empty list inserts none. The original `nt_join_go` prepends its existing
   accumulator exactly once. Empty element strings do not affect separator
   placement.
3. `nt_lines_rev` accumulates the reverse of the desired output. A newline pushes
   four spaces and a newline in that order, then a final String reverse restores
   newline followed by four spaces. A direct Bool match in `nt_lines_char`
   avoids eagerly constructing two closures holding the growing accumulator.
   Non-newline Unicode characters are copied unchanged. `nt_lines_go` preserves
   its preexisting accumulator verbatim, including any unindented newlines.
4. `ne_segments_chunks` records the existing `ne_segment(h)` result and its
   trailing newline in reverse output order. Segment rendering order and all
   host/spin wrappers remain unchanged. `ne_segments_go` retains its prefix.

This replaces repeated copying with linear character work plus small chunk-list
nodes. It adds no memoization, function-name special case, target-specific
semantic rule or runtime representation. The main risks are reversed chunk or
newline order, accidental separator changes, JS throughput regression from a
different string shape, and chunk-list peak lifetime. The direct branch avoids
the closure-capture issue identified independently in the native Map audit.

The active `ne_template_join` already assembles a fixed five-part canonical
runtime using bounded fragment appends toward a recursive suffix. It is left
unchanged. `nt_replace_step` and the raw scanner are also excluded from this
first candidate to keep attribution narrow.

## Bounded controls and scaling screen

[string-builder-controls.bend](string-builder-controls.bend) is a separate entry
to concatenate with the current compiler modules. It calls the real helpers
and works unchanged before and after the patch. Its 21 assertions cover empty
inputs/elements, nonempty accumulators, initial `first=False`, separators,
newlines, CR, Greek and astral Unicode, and empty/single/multiple segment lists
with host/spin flags. The segment comparison includes the original reducer as
an independent local reference. Its `main` must check and return `True` in JS
and native C. This lane authored it; root owns compilation and outcomes.

The same file exposes three size-parameterized calls using the real helpers:

| Function | Initial sizes | Expected output consumption |
| --- | --- | --- |
| `p87_scale_lines(n)` | 1,024 / 2,048 | Exactly `6*n` characters, compare complete bytes |
| `p87_scale_join(n)` | 512 / 1,024 | Exactly `10*n-2` characters for positive n, compare complete bytes |
| `p87_scale_segments(n)` | 32 / 64 | Repeated identical rendered segment/newline; compare complete bytes |

Constructed input uses linear reverse accumulation, so it should not hide a new
quadratic setup cost. Time a fully consumed result from original and candidate;
do not time a returned lazy closure or use constant-only folding as evidence.
If the small sizes fall below timer resolution, grow only the relevant size and
retain a short timeout. Three helper pairs plus the 21 semantic assertions are
the cheap falsifier. The full-image four-source exact-output screen follows
only after these pass; both native and sibling JS must be measured.

The frozen patch is not promoted by this report. Even a large native Lexer win
does not fix Map, native Base startup, native B2 feasibility, or the production
JS-hosted compiler's cold compilation deficit.
