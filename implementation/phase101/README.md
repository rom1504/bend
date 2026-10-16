# Native text: a promising representation prototype

The ambitious agenda is now [recorded](../../design/phase101/ambitious-native-agenda.md).
Its first experiment produces a substantial **complete-renderer** win: the final
six-round comparison takes **0.585× baseline time on one worker and 0.603× on
four**, using about one-third the peak memory. It also beats upstream C on this
workload: **0.763×/0.894×** its elapsed time respectively.

This is a **host-only generated-C prototype**, not a newly installed compiler.
Indexing remains slightly slower and graph planning regresses 4–6%, so do not
promote the representation globally yet. The installed Phase98 native B1/B2 and
Phase90 JS releases are unchanged; no new compiler-throughput, full-self,
whole-language conformance or formal-proof result is claimed.

[Machine-readable results](results.json) ·
[Representation audit](text-representation-audit.md) ·
[Independent review](prototype-review.md) ·
[Replay instructions](../../selfhost/tools/performance/phase101/README.md) ·
[Evidence](evidence/README.md).

## What changed

Ordinary String construction and traversal previously used a linked constructor
per character plus ownership wrappers. The prototype retains the logical SNil/
SCon interface but introduces a packed cursor with a new runtime tag. A chunk
contains an atomic reference count, an owned suffix, an end boundary and up to
61 characters. Each eight-byte cell carries the complete U32 Char and the offset
back to its chunk header. A suffix is a cursor, not a copied linked list.

This deliberately preserves more than Unicode scalars: Base Char can contain any
U32, including NUL, surrogates and values above Unicode. The existing UTF-8 IO
decoder/encoder remains the boundary behavior. Static linked literals coexist
with packed storage. Generic consuming matches, borrowed observers, nested
destruction, Array replication, shared-observer routing and readback all handle
the new representation.

Construction can prepend into unused space of an exclusively owned chunk.
Append packs a bounded short prefix into the right-hand builder; longer prefixes
can reuse exclusive chunks and copy shared portions. A borrowed comparison
helper compares packed spans as unsigned U32 values while preserving both owners.
These are general String operations, with no application-name dispatch. The
three C helper fragments total 173 physical lines; the prototype transformation
and experiment tools add separate scaffolding. Canonical compiler line counts
and concept counts are unchanged because this is not integrated into the emitter.

The worker-name replacements are experimental adapters for the pinned canonical
Base operations. Production lowering must establish their checked structural/
type identity, preserve evaluation order, and define a device fallback or device
representation. A name match alone is not an acceptable general compiler rule.

## Measured results

The final screen alternates baseline/candidate/upstream order across six rounds.
Programs use identical Bend sources and inputs, the same pinned Clang22 C11/O3
build settings, CPU3 for one worker and physical CPUs0–3 for four. Times include
process startup, input, computation, complete stdout capture and shutdown;
compilation, Clang and oracle generation are outside these clocks.

| Complete application/input | Workers | Installed B2 output | Prototype | Upstream C | Prototype / baseline | Prototype / upstream |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Renderer, 512×384, 1024 iterations | 1 | 357.8 ms | 209.4 ms | 274.5 ms | 0.585× | 0.763× |
| Same renderer/image | 4 | 169.9 ms | 102.5 ms | 114.6 ms | 0.603× | 0.894× |
| Index 1.75 MB compiler source file | 1 | 201.5 ms | 207.2 ms | 93.3 ms | 1.028× | 2.221× |
| Index generated 10,000 declarations | 1 | 120.3 ms | 121.5 ms | 68.8 ms | 1.010× | 1.766× |
| Dependency DAG, 800 nodes | 1 | 231.0 ms | 245.3 ms | 684.5 ms | 1.062× | 0.358× |
| Dependency chain, 1000 nodes | 1 | 230.1 ms | 238.7 ms | 636.7 ms | 1.037× | 0.375× |

The indexing rows are **application execution**, not requests to compile that
source. Do not interpret them as compiler speed measurements. The shorter
upstream index times are below the conservative 100 ms threshold, so small
ratio differences there deserve caution. There is no universal aggregate ratio.

Renderer peak child RSS falls from **79.4 MiB to 25.4 MiB**, at both worker
settings. Indexing the compiler source falls **48.0→19.9 MiB**. DAG memory rises
about **7.4→8.9 MiB**, another reason to avoid unconditional deployment. The
renderer still scales about 2× across four cores; this improves sequential and
parallel costs, but does not yet achieve the agenda's 3× scaling aspiration.

The final renderer ranges are 197.0–211.3 ms candidate versus 345.6–373.2 ms
baseline at one worker, and 100.4–112.1 versus 152.4–178.6 ms at four. Upstream
ranges are 255.6–275.8 and112.8–117.8 ms. An earlier four-round packed-builder
comparison independently showed 0.561×/0.593× baseline time. Retain all samples;
these are observed ranges and medians, not confidence intervals. An intermediate
graph screen had visibly variable clocks; the final six-round graph rows above
supersede it for the decision and show the remaining regression clearly.

## Why this worked, and what did not

Unchanged-image physical sampling finds a large renderer text path: **19.0%** of
samples in the append worker, **16.1%** in its SCon reconstruction continuation,
**11.5%** in `rfc_wrap`, and **4.6%** in allocation misses. Arithmetic is 29.3%.
These leaf shares do not prove that every ownership/allocation sample belongs
to append, and are not additive speed forecasts. The controlled interventions
give the stronger result:

1. **Storage alone is insufficient.** Packed input/constructors reduce memory,
   but indexing stays roughly flat; renderer one-worker time regresses in the
   first screen. The old append still pays per-character continuation costs.
2. **Naive chunk splicing also loses.** Retaining a largely empty 512-byte chunk
   for each short formatted prefix raises renderer memory to about506–507 MiB
   and slows it 1.46×/1.80× versus baseline. This rejected version is preserved.
3. **Packing short prefixes makes the architecture useful.** It eliminates
   those sparse chunks and lets append operate without a reconstruction frame
   per character. Full rendering then becomes roughly 1.7× faster in the final
   screen, with much less memory. The operation and representation must agree.
4. **Consumers need the same treatment.** The batched borrowed comparator reduces
   some graph overhead, but does not remove the final 4–6% regression. We have
   not separately profiled that regression or established its full cause.

Source indexing exposes a different boundary. In 476 accepted samples, three
continuations saving/restoring roughly 10–15 values account for 34.5%; `term_drop`
is 10.9%, while `io_str` is only 2.3%. In 546 renderer samples, append/reconstruction
is prominent instead. Merely making file decoding faster cannot remove indexing's
whole gap. This strengthens the second ambitious direction: propagate typed
scalar/cursor and loop-state facts through complete functions, reducing those
continuations and redundant ownership operations.

Profiles cover all created threads, with >=95% process CPU coverage and zero
drops/overruns at 8/13 ms periods. They use actual unchanged ELF images and check
full output. Two earlier 1/2 ms captures overran and remain rejected diagnostics.
No dynamic allocation census, logical call-tree reconstruction or new optimized
candidate profile is claimed.

## Correctness and limits

The final prototype passes **90 independent control executions**: ten cases,
three variants, and 1/2/4 workers. The controls cover all-U32 Char observations,
malformed UTF-8 replacement, embedded NUL, dynamic overlapping append in both
orders, retained roots/tails, exact 60/61/62-character boundaries, 260-character
crossings, Array replication/update/drop, and shared parallel output.

The final saved products also pass **all 50 Phase100 application inputs** in
165 full-output executions, plus 108 executions in the repeated screen. That is
**363 successful executions** for the final prototype/baseline/upstream campaigns.
Earlier variant controls, profiles and experiments remain separate in results.json.
The independent Python expectations are reused by hash; no changed oracle is
substituted to accept the prototype. Root acquired upstream safe admission for
the control sources before measuring their transformed native-B2 output.

An offline reviewer checked the concrete ownership invariant: every owned cursor
retains its chunk, every chunk owns a sealed suffix, and borrowed views stay
within held-root lifetime. The review is not a formal proof or proof of the
entire emitter. GPU, arbitrary foreign/forged Terms, every existing backend test
and genuine B1→B2 qualification remain outside this experiment's claims.

Retained failures include a preparation-pattern mismatch, the timer overruns,
an older fixture-report shape rejected by the profile harness, an Array control
rejected for matching a computed value, and an append adapter bug. `WL_OPEN`
declares a new register bank: the first adapter accidentally read shadowed,
uninitialized arguments. Saving incoming arguments before that macro fixes it.
The resulting failures and a diagnostic debug run are not successful controls.

## Efficient next step and decision

**Keep and develop this prototype; do not install it globally yet.** It proves
useful representation-level headroom on an ordinary complete application, beyond
a tiny synthetic kernel. It has not met the proposed stronger gate of substantial
gains on two distinct applications and a small compiler request. Consequently we
did not pay for another full compiler build or claim a compiler-speed gain.

The next bounded experiment should compare the graph's old/new physical costs
and test cached typed String cursors or an adaptive small-string representation.
Also ablate direct iterative append while retaining linked storage, to quantify
how much of the win needs the new ABI. Then connect the winning operation through
certified Bend emitter lowering. The indexing continuation profile supplies a
concrete starting point for whole-function typed lowering; it should accompany,
not be hidden behind, a claim that all text is now fast.

Routine iterations build an application, not a compiler image. The four-round
renderer acquisition/comparison took 13.4 seconds; frozen products can replay
without rebuilding. Final control acquisition reuses checked baseline/upstream
products and builds only candidates. Across the entire experiment, 750 serial
guarded jobs occupied 226.8 seconds during a 16-minute first-to-last target span.
Peak process-tree RSS was 518.4 MiB, including the rejected sparse-chunk version;
there were no resource stops, OOMs or target overlaps. Three collaborators worked
offline on ABI review, independent controls and profiling preparation. No PR
comment was posted, and quota percentages are unavailable.
