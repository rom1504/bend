# Exact native stage profile on the qualified Phase143 compiler

The full stage capture passes the unchanged115,909,112-byte output oracle,
actual ELF/dispatch binding, required marker order and sample-ordinal checks.
There are10,283 samples, no drops or overruns, and99.596% sampled-thread/process
CPU coverage. The actual final-admission path calls `p126bp_complete` once, so
its entry-to-writer interval is available here. On the small Lexer pilot this
conditional branch is absent; v01's rejected assumption remains preserved.

The following are measured **diagnostic entry intervals**, including scheduler,
reference management and continuations between the named entries. They are not
clean function-body costs. The stage sum330.632s covers all but0.183s of the
330.816-second child wall observation. [Exact data and input pins](stage-profile.json).

| Computation | Wall seconds | Interior samples | Main active owners |
| --- | ---: | ---: | --- |
| Base preparation | 0.231 | 5 | Too short for quantitative sampling |
| Parse/load | 47.950 | 1,497 | `f_find`480; `f_eq`96; `f_grow_base`45 |
| Checking/publication | 37.327 | 1,164 | `p131i_insert`159; `constructor_exists`125; `book_final_seen`71 |
| Proof dependency report | 2.229 | 68 | `dr_own_names`58, descriptive only |
| Owned/main eligibility | 0.215 | 5 | Too short |
| Checked context reconstruction | 3.959 | 121 | `constructor_exists`71; `norm_max_book`14; `lookup`14 |
| Annotation/reach | 6.976 | 216 | `lookup`33; `subst_node`19; `kr_resolve`17 |
| Layout check | 2.560 | 78 | Several layout helpers; descriptive only |
| Erasure/finalization | 15.785 | 492 | `nc_ctor_owned`307; `lookup`34; `norm_max_book`23 |
| Runtime admission/certificate | 0.078 | 0 | Too short |
| Static preparation | 4.986 | 154 | `p112s_term`16; String helpers; descriptive only |
| Raw generic/private lowering | 44.631 | 1,393 | `nc_ctor_owned`197; `nc_uses_term`93; `lookup`73 |
| Initial private admission | 1.112 | 32 | `p113d_deps`15, descriptive only |
| Initial optimizer | 41.635 | 1,299 | `p111v_get`220; `p113k_get`117; `p131i_insert`105 |
| First independent verifier | 22.396 | 698 | `p111v_get`122; `p111v_value`62; name checking61 |
| Observer permission/discovery | 4.215 | 128 | Effect/layout/ownership queries; descriptive only |
| Observer composition and selected final admission | 24.219 | 755 | `nc_ctor_owned`87; `p111v_get`79; `nol_scalar_specs`66 |
| Registry preparation/finalization | 18.284 | 567 | String equality/append; region buffers; ready-index work |
| Render/output/exit tail | 51.845 | 1,568 | `String.append`350; `p111q_memory`136; `p111q_body_text`104 |

Inside the24.219-second observer interval, the actual `p126bp_complete` entry to
writer takes **10.056s**. It includes return/continuation overhead. This nested
interval must not be added to the table's totals. There are314 ordinal slots in
it before conservative edge exclusion; a precise hot-function distribution is
not established from that small count. Missing/repeated conditional entries
would suppress this separate timing, rather than reinterpret the branch.

The immediately preceding residual diagnostic took324.306s; adding stage clocks,
ordinal capture and the new diagnostic relink produced330.816s (+2.01% wall,
+1.97% process CPU). This is one observation each, with possible host variation
and code-layout effects. It is not a clean profiler-overhead estimate and does
not establish instrumentation neutrality. The296.541s historical clean reference
was measured with N1; this profile uses qualified N2 with the same program-object
bytes. Do not advertise330.816s as clean compiler speed.

## What the stages say about ambitious optimization

**The remaining cost is distributed.** Frontend through erasure is117.000s;
admission/static/raw lowering50.806s; initial optimization and its subsequent
independent verifier64.031s; observer work28.434s; registry18.284s; output tail
51.845s. These partitions use disjoint entry intervals. They cannot be replaced
by the sum of hot helper percentages, whose physical and logical views overlap.

The existing registry plus output path consumes70.129 diagnostic seconds by
itself. Therefore a50-second whole-request objective requires improving these
stages too, even if frontend optimization becomes exceptional. This is an
observed implementation floor, not a lower bound on what a different design
could achieve. `p111q_body_text` already uses chunk finishing; another generic
"replace concatenation with a list" proposal needs to identify actual remaining
construction and copying, rather than assume a growing-prefix implementation.

The first independent verifier and the conditional final-admission interval
together occupy32.453s, about9.8% of this diagnostic request. Even deleting all
of that work would not reach the target—and deleting it is not an acceptable
correctness optimization. Shared immutable value/header facts or compact local
IDs can still reduce its lookup, construction and reclamation cost. The much
larger64.031-second optimizer/first-verifier region means reusable facts should
be tested across transformations, while preserving the independent final gate.

Constructor ownership is concentrated in erasure and raw lowering, with another
appearance during observer composition. A shared exact ownership view can
therefore transfer across real stages. The sample counts establish repeated
work, not that every such call can legally share one context or that catalogue
construction is free. Preserve each stage's book/layout identity and first-match
semantics, and measure preparation plus queries plus destruction.

Parser lookup is an attractive bounded experiment but does not explain all
47.950s of parsing: `f_find` has480/1,497 interior samples (32.1%), `f_eq`96
(6.4%). Their approximate sample-period amounts are15.36s and3.07s. These are
upper ceilings only for eliminating the observed entire named computations,
not a prediction for one partial index. Checker/publication now has a distinct
37.327-second budget with distributed insertion, constructor validation,
publication finishing and actual checking; the old repeated publication removal
is no longer the dominant measured story.

## Parser caller question: what we cannot infer

The active context becomes `f_find` when its body executes. It does not retain
which source consumer called it. The current physical unwinding covers selected
libc leaves, not general generated Bend calls. Phase and sample order establish
that these samples occur in parse/load; neither identifies the four consumers
changed by `parser/prior-v01.bend` versus `f_decl_local`.

In the frozen executing source, four direct prior users are
`f_context_family_input` (line11852), `f_context_mark_input` (11950),
`f_do_header_resolved` (13359) and `f_do_resolved` (13475).
`f_decl_local` (12957) still calls `f_find` on its local book after an index
membership test. Alias filling (14901) and the incremental type-constructor
header (58522) are other distinct source sites. The source inventory does not
prove their dynamic proportions. Empty-list `f_find` fallbacks also exist and
should not be counted as long scans merely from call frequency.

**No defensible current number attributes the480 samples to those four changed
consumers.** A targeted site-origin diagnostic is needed to identify that split,
or a controlled complete parse experiment can directly measure the proposed
index's benefit without solving caller attribution. Do not extrapolate the full
`f_find` budget to the partial prior-view change.

## Reusable profiler capability worth retaining

The delivered-sample-count getter and stage clocks are useful beyond this compiler
phase. A small versioned generic facility could accept an authenticated binary,
owner map and data-only stage plan: exact FIDs, labels, required order and explicit
multiplicity (`once`, `first`, separately observed conditional). Its output would
join measured clocks, ordinals, ELF addresses, independent output checks and
per-stage distributions. Compiler-specific names and interval labels stay in
the workload manifest.

The minimum promotion is to factor the source-preserving sampler delta and
runtime marker generator into versioned utilities, plus a data-only stage report.
Retain old `sample.c`, old sampler receipts and old phase evidence unchanged.
The generic runner should pin the sidecar alongside samples/contexts/callers;
stage validity remains a separate gate. Preserve zero-loss/coverage checks,
unknown denominators, edge exclusions, conditional invocation records, local
sample-count limits and explicit diagnostic timing. A second noncompiler
workload is a useful transfer test before calling the interface generally
qualified. No larger profiling framework or compiler rewrite is required.
