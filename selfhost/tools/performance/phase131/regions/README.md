# Shallow borrowed query experiment

Experimental candidate over qualified Phase130. No production edit or
selection change. The coordinator owns clean measurements and promotion;
bounded CPU6 correctness builds use the shared guard.
The initial checked acquisition rejected one missing `KDef` annotation in a
finite control; `controls.bend` and `regions-source01` retain that attempt.
`controls-v02.bend` supplies the annotation; the compiler transformation is
unchanged. The coordinator's `p131-regions-api02` receipt now confirms checked
API acquisition (15.13 seconds, 2.18 GB peak process-tree RSS). This is not yet
runtime qualification.

`shallow.bend` overrides only `p128bl_node`. Existing complete layout discovery
is tried first. On failure, a nonnative, nonparameterized record/sum may expose
up to eight constructors, each of width zero or two through eight. One-field
packed layouts remain refused. Existing scalar and old-spine field types stay
visible; all other fields receive a reserved opaque abstract type. Only visible
spines enter the layout graph. The root stays held by the unchanged adapter.

The opaque type is absent from the source book and every layout. The unchanged
NO evaluator consequently refuses its matching, scalar conversion, borrowed
reader argument conversion, result escape and recursive-root promotion. An
inlined helper may ignore such an argument, which is safe. This is not a claim
that opaque words can be passed to arbitrary owning runtime calls. Unknown
effects/calls and unsupported computations retain original owning fallbacks.

Prepare (composition only):

```sh
python3 -B selfhost/tools/performance/phase131/regions/prepare.py \
  --out selfhost/build/phase131/regions-source02
```

That output already exists in this workspace. Its SHA256 is
`e5f32523997b25728585bca4d25cd3439de395a5ca1142c491e90c0305dfeb5c`.
Use a fresh output path for another composition. Parent SHA256 is
`995d6b4bf14963debb9a810de2ed941c3cd30a71fc34a156d96b1adbd1b06bdd`.

Acquire the checked API under the root guard using existing
`phase111/check-api.py`, with exports:

```text
p88_cache_prepare p86_plan p111_emit_admitted p111_compile_source
p128br_diagnose p131rg_controls p128bl_controls p128br_call_controls
```

Then the root executes the finite checks:

```sh
node selfhost/tools/performance/phase131/regions/finite.mjs \
  API_REPORT selfhost/build/phase131/regions-finite01 \
  '{"p131rg_controls":13,"p128bl_controls":7,"p128br_call_controls":10}'
```

The runner is derived unchanged from Phase128's authenticated finite runner,
except repository-root depth and fresh-output directory. All predicates execute
in the checked Bend API. Synthetic abstract values are never executed as native
IR. These finite gates do not replace ordinary runtime checking.

`prepare-fixture.py` freezes exact Phase130 `KTerm`, equality and tag-query
definitions, with source spans/hashes in `oracle.json`. It adds an unrelated
three-constructor packet query and ordinary opaque-payload controls. No original
query algorithm is rewritten. Both cases have the same independent twelve-line
ordinary output in `expected.stdout`. The generator does not execute Bend.

```sh
P118_CASE_MANIFEST=selfhost/tools/performance/phase131/regions/cases.json \
P118_RUNTIME_REPORT=PHASE128_RUNTIME_REPORT \
node selfhost/tools/performance/phase128/emit-entry.mjs \
  API_REPORT SOURCE_MANIFEST \
  selfhost/build/phase118/p131-regions-emit01 compiler-tag record-transfer
```

Use this request-bound entry, which invokes `p111_emit_admitted`. The older
Phase118 diagnostic emitter explicitly lowers through `p113a_lower_request`
and bypasses the current integrated borrowed-reader path. It cannot test this
candidate's actual selected emission. The retained Phase130 checked API exposes
the necessary entry and admission functions.

`jobs.py --out selfhost/build/phase131/regions-jobs01` prepares complete root-only
guarded commands: finite controls, parent/candidate integrated emissions, four
aligned builds with exact ordinary stdout, admission diagnostics, then a sealed
manifest for the existing generic profiler's clean paired runner. It executes
nothing. Root must run jobs in order and stop after any failure. Its seal step
checks all four build receipts and their independent ordinary oracles before
producing timing inputs; no new measurement framework is introduced.

The two cases differ only in the repeated query. All other source and ordinary
controls are common. Use the existing aligned build recipe and frozen complete
stdout. The final native argument `100000` selects 100,000 timed repetitions;
the exact prefix is `1\n100000\n`, followed by one elapsed integer in
**milliseconds**. Zero/no numeric argument selects ordinary controls. Change
repetitions in a fresh run manifest with expected sum `repetitions mod 2^32`;
the presets have not been calibrated. Do not feed this output to a legacy
benchmark runner expecting warmup/success-count fields.

Inspect actual selected `$p118borrow.read.*` symbols, owning fallback calls and
complete machine behavior. `p128br_diagnose(request, owner)` must demonstrate
positive admission for `p98_tag_eq[_read]` and `p131_packet_[query|read]`, and
refusal for `p131_opaque_count`/`p131_opaque_escape`. Correct output with fallback
alone is not evidence of an optimization. The owning roots, nested aliases,
Unicode, three different KTerm constructors, unused payloads and refusal paths
are exercised by the ordinary fixture; retain existing Phase128 alias/depth
controls as well.

Measure compiler overhead on exact same source/API inputs. This adds a fallback
layout analysis to an existing pass, not a new pass or runtime ABI. It could
increase analysis on many previously refused functions; stop if query savings
do not amortize it. Baseline `p98_tag_eq` is already a private function, so this
first experiment primarily removes ownership work **inside** the query. It does
not establish removal of the caller's generic register transport.

Second iteration is isolated in `virtual-v01.bend`, composed with
`prepare-v02.py`. Source03 adds exact-body partial evaluation for verified
reader calls with finite typed virtual constructor arguments. The raw borrowed
pointer gate remains unchanged. The first API acquisition hit its 2GiB guard;
the fresh 3GiB retry (`p131-regions-api04`) passed checking and all 39 finite
controls. `regions-diagnose03.json` confirms compiler tag query/read and packet
query eligibility. This is legality evidence, not runtime evidence.

Source04 additionally includes `late-inline-v01.bend`. It moves the existing
inliner after borrowed-worker installation, preserving initial and final
independent checking. It specifically tests the first attempt's lost-call-site
problem: despite selected packet readers, both timed loop/caller QBE bodies
were exactly unchanged because the old owning bodies had already been inlined.
See `attempt01-evidence.json`. Source04 remains experimental; API numbering is
independent of source numbering, so always inspect the receipt's source pin.

Source04's actual emission was a negative: selected tag/packet readers were
absent, and shorter caller bodies only moved owning work into callees. Source07
(`late-inline-v03.bend` plus `late-controls-v01.bend`) retains the old verified
proof snapshot for summary discovery, applies workers to uninlined callers,
then uses the existing borrowed-import projection contract around late inlining.
Its checked API and all 46 finite controls pass. All three native ordinary
oracles pass; root-owned clean timings show 57.73% and 52.76% runtime reductions
on the two query proxies. QBE grows 49–52%, and duplicate preparation is costly;
this schedule remains unselected. See the research note for exact scope and
the two earlier staging failures.
`replay.py` prepares three aligned ordinary builds and clean paired timing from
an existing complete emission, reusing the frozen baseline binaries; it never
executes targets itself.

`uses.cases.json` provides another, more representative **compiler computation**
proxy. `prepare-uses.py` extracts unchanged `nq_uses`, its mutually recursive
list/pattern helpers and seventeen supporting definitions from the pinned source.
Ten ordinary occurrence-count outputs are independently frozen. Its timed
`-- 1000` contract is `2\n2000\n` plus one elapsed-millisecond line. A depth-seven
tree stays retained across repeated queries for present/absent variable IDs;
the graph shares children, while each traversal observes 255 logical nodes.
The initial repeat count is uncalibrated. This does not represent a complete
compiler request or the frozen user-program benchmark.

This proxy is useful because the actual compiler's larger recursive caller
retains private tag-query calls, whereas the first tiny fixture had inlined them
before replacement. Compare the already checked source03 against Phase130 here
before concluding that all benefit requires more expensive pass rescheduling.
Both existing negative fixtures remain frozen. Use the integrated emitter and
`compiler-uses.expected.stdout` for its ordinary aligned-build oracle.

The exact compiler occurrence proxy has now emitted and passed ordinary native
outputs for Phase130 and source03. Its retained recursive caller reaches the new
borrowed tag adapter without source07's duplicate preparation. `uses-timing.py`
seals these already built products into the existing profiler manifest; it does
not execute targets. Its initial 1,024-repeat pilot is followed, if needed, by
`--pilot-report REPORT --out FRESH_OUT` to choose a 500 ms fastest-variant workload.
Root owns clean CPU3 runs.

`inspect-results.py --out FRESH_OUT` preserves existing result pins and selected
QBE/host-disassembly snippets for both experiments without executing Bend.
Static sites across mutually exclusive branches are explicitly distinguished
from dynamic work. See [the research report](../../../../../research/phase131/private-regions.md)
for measured gains, code growth and why source07 is not selected.

The source03 occurrence-query transfer is now measured: parent median 595.33 ms
versus 479.70 ms over three clean paired CPU3 rounds at 2,047 repeats, a 19.42%
runtime reduction. All timed outputs pass. See `attempt04-nq-uses.json` for
pins/raw rounds; this is an extracted compiler computation on synthetic shared
trees, not a full compiler request speedup. It needs no source07 scheduling
overhead. Source07 remains excluded because its useful proxy ceiling comes
with duplicated preparation and 49–52% QBE growth.
