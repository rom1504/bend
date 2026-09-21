# Phase 2 implementation report

Work began on 2026-09-21 at 14:10 UTC, with a 17:10 UTC cutoff. This is a
progressive report; later sections record completed validation rather than
assuming every design objective has passed. The
[design](../../design/phase2/fast_conformance_loop.md) was committed and pushed
as `9e7a56d` before implementation.

## Starting baseline

The historical frozen phase 1 corpus has completed all 6,019 probes across 1,378
fixtures. Its `coverageComplete` is true and its conformance `complete` is false.
The [compact archived summary](evidence/phase1-completed-corpus-summary.json)
records the exact compiler, runtime and host identities and hashes the complete
local report. This is the older H4 compiler, not a phase 2 candidate.

All 919 positive check probes accept. The strict check lane reports 1,001 passes
and 377 failures; many failures concern diagnostic or rejection-phase differences,
so this is not a count of 377 invalid acceptances. All 459 negative check
observations retain the earlier behavior. Seven observations changed: three
native timeouts, two borrowed-list JS/IO interpreter failures, one native stack
fault with missing output, and one diagnostic presentation change. GPU probes
remain hardware-gated.

## Runtime host corrections

Fresh probes reproduced the borrowed-list and native stack-fault failures with
the phase 1 checked B1 compiler (`37ebe8ae…`). They have distinct causes:

* The conformance worker had an explicit 4 MiB Node stack, while its generated
  JavaScript child used Node's smaller default. The identical emitted
  `reg/borrow_fork_hold.bend` program prints the required `2003000` when launched
  with the worker's 4 MiB setting. The typed driver now propagates only explicit
  stack and old-space limits, and records them in runtime results. It does not
  forward evaluation, loader or debugger options. This is a host resource-policy
  correction, not a compiler optimization or a general elimination of stack
  limits.
* The native SIGSEGV/SIGBUS handler called `err_post`, then buffered stdio through
  `err_fail`. Replacing those operations with a fixed `write` and `_exit` makes
  the overflow print the required diagnostic and exit 1. The handler now uses
  only async-signal-safe operations. This removes a demonstrated failure path;
  it does not prove every possible signal delivery scenario on every platform.

The two unchanged pinned fixtures pass all six fresh interpreter, JS and native
probes after the changes. In particular, the extreme-depth fixture still fails
loudly with its required message and exit status; giving JS the declared stack
does not turn that negative execution into success. Dedicated subprocess tests
also verify resource-option propagation and exclusion of execution options.

## Frontend investigation

Fresh differential witnesses were run against the pinned TypeScript APIs
and explicit checked Bend APIs. One initial hypothesis was falsified:
although the frontend accepts an explicit arrow in a law fill, the downstream
signature guard rejects a changed return type. There is no demonstrated type
signature override. A redundant same-type arrow is still an invalid acceptance
relative to upstream syntax and is now rejected.

The three frontend modules now enforce four existing upstream rules:

* A definition filling a law uses plain parameters followed by `:`, with no new
  return annotation.
* Template `~` law clauses form a leading prefix, before ordinary or erased
  clauses.
* Local assignment patterns pass the same constructor/binder validation as
  match patterns, including braces and field counts.
* Imports precede declarations and cannot follow an `@unsafe` decorator. The
  current top-level grammar only adds declarations to its initially empty book;
  this invariant makes the empty-book test an exact import-region boundary.

The [before](evidence/frontend-before.json) and
[after](evidence/frontend-after.json) reports retain 21 live differential cases:
12 negative witnesses and nine valid controls. Nine invalid acceptances are
closed, two rejections move from checking to the required frontend phase, and
one existing frontend rejection is preserved. All nine valid controls continue
to accept. Exact diagnostic text remains a separate obligation. The changed-type
law example belongs to the phase corrections, not the invalid acceptances.

The final focused matrix took 9.064 seconds with a reused API and warm Base cache:
6.854 seconds in candidate calls and 1.965 in reference calls. The before matrix
took 28.488 seconds, partly because invalid syntax reached later expensive gates;
that difference is not a general compiler speedup. Initial witness authoring
also exposed two invalid positive controls; those were corrected rather than
weakening the language rules, and the earlier local attempt is retained.

The [checked bootstrap](evidence/frontend-bootstrap.json) identifies API
`8ae7a4cebb236c2bf83863417d433093b858f2831b6a32d8823ebf52f271eff1`
and assembled source
`2f0b4956987479763c0d2a4d06dfc5a17dd96dac5126ad72266b7347e8feb635`.
The independent [component verification](evidence/components.json) passes all
19 groups, including the dependent checker, diagnostics, index, loader, prefix
cache, freshening, specialization and primitive runtime. Its checked build and
all tests took 34.596 seconds on CPU 1; this is a single observed development
cycle, not a repeated benchmark median.

A frozen full checked self-emission/fixed-point run has started on CPU 1. It is
independent of the targeted loop and is not counted as passed until both emitted
stages finish and their hashes agree.

## Targeted differential harness

The new `tools/conformance/target.mjs` builds no compiler. It verifies an explicit
checked API, freezes its host and harness, then compares exact selected probes
with live pinned TypeScript APIs. It preserves fixture-oracle verdicts separately
from compiler agreement. Exact pair selection, failure-first queues, retained
replays, bounded output, process-group deadlines, artifact/input drift, expected
missing files and symlink identities are tested. Replay verifies Node identity
and restores the recorded compiler configuration without inheriting unrelated
current overrides. Dirty tracked upstream source/fixtures are rejected.

The live reference uses upstream load, check, ownership, normalization and backend
APIs, including declaration reporting and the `PROOF.bend`/`LAWS.bend` policy.
Its exported loader combines loading and parsing, so some filesystem errors have
coarser phase labels than the port. Missing Bun-dependent effects are unsupported.
Neither limitation is hidden by substituting the Bend port into the reference.

The [21-case paired attempt](evidence/targeted-custom21.json) completes in 30.203
seconds with independent workers and retained artifacts. Both compilers satisfy
all selected acceptance/phase oracles; all 12 diagnostic differences remain in
the report. This has more isolation and replay overhead than the nine-second
in-process focused matrix. Neither result sets full-suite `complete` to true.

The [18 original adjacent fixtures](evidence/frontend-upstream-adjacent.json)
agree semantically, including six positive controls. Twelve exact negative
diagnostics still differ, so that attempt correctly has `selectedComplete=false`.

## Native graph host: first candidate

The native entry now accepts an explicit module/asset manifest. It supplies raw
sources to the existing Bend graph loader, preserves canonical module identity,
checks all normal compiler gates, and reads only JavaScript foreign assets
selected after reachability. Logical foreign binding paths are preserved.
The filesystem wrapper validates the bounded transport, protects input/output
aliases, checks drift, and publishes by atomic rename only on success. The old
main-plus-Base entry remains available.

The [first native matrix](evidence/native-graph-v1-validation.json) passes 19/19
cases. Valid outputs are byte-identical to the JS host running the same checked
Bend program and produce the expected execution results. Cases cover imported
graphs, diamonds, repeated imports, Unicode and symlink identities, conflicts,
cycles, imported syntax/type errors, templates, ADTs, library exports, shared
foreign assets and unused/missing inputs. A required file deliberately omitted
from an explicit manifest is a documented scope difference from automatic JS
host discovery; missing-module load/parse labels also differ.

The [native harness route](evidence/targeted-native-smoke.json) also passes a live
upstream comparison for `base/list_sort.bend`. It explicitly records native
compiler execution and JavaScript program execution. Its only conformance lane
is `js`; unsupported lanes never fall back to a JS compiler. Paired native
manifests must use the canonical pinned Base file.

Decoder/lookup and filesystem boundary tests accompany the host. Initial driver
build attempts caught syntax issues before successful checked emission. The
first matrix ran before the final tool-provenance hardening; its preserved local
launcher reconstruction is labeled accordingly. The second candidate's matrix
will verify the complete consumed tool/build identities. The first candidate's
[source preparation](evidence/native-graph-v1-preparation.json) is distinct from
the next source revision and is not silently updated.

See the [development guide](../../docs/PHASE2_DEVELOPMENT.md) for build, selection,
replay and native-manifest recipes. Broader validation and final timings will be
recorded as they complete. No whole-suite conformance or native self-hosting
claim is made by this interim report.

## Second grammar revision

The new differential loop exposed two further grammar defects, documented in the
[follow-up investigation](frontend-followup.md). The second frozen revision
requires an explicit `:` and type on marked (`~`, `+`, `-`) parameters while
preserving permitted plain quantity parameters and plain names filling laws.
It also rejects semicolons at list-element boundaries. This is a local delimiter
repair, not a rewrite of general statement whitespace; valid body and IO
semicolons remain supported. The list builder now propagates argument-parser
errors instead of turning an error's empty child list into an empty literal.

The [25-case paired matrix](evidence/frontend-grammar-v2.json) passes on both
live compilers: ten additional invalid acceptances are closed and 15 valid
controls pass. The [earlier 21-case matrix](evidence/frontend-v2-existing21.json)
also remains green. Two original upstream syntax fixtures now reject at the
matching frontend phase, while their exact diagnostic differences remain visible.
Together the two focused matrices demonstrate 19 closed invalid acceptances;
this is a count of witnesses, not 19 independent language rules or a full-suite
conformance percentage.

The [second checked bootstrap](evidence/frontend-grammar-v2-bootstrap.json)
identifies API
`794cbf5f00a0a3a29f53821d530d27211c217a0636da14082adcbb18f4e5f2b6`
and source
`266933eb2ee6aa0d406a48b19f5bbe0250c6685e9f5f2d9fe276bc38bac31784`.
All [19 component groups](evidence/components-v2-shared-cpu.json) pass, including
35 individual harness/host tests in the expanded final group. This validation
shared CPU 0 with the reference sweep and another bootstrap; its 129.7 seconds
are not an isolated iteration-speed measurement. `BEND_COMPONENT_DIR` now keeps
each requested component build and report in a fresh directory.

The first native full-source run was rejected at publication because a concurrent
bootstrap rewrote `dist/base.bend` with identical bytes, changing its metadata.
The guard correctly withheld the temporary output. Bootstrap now avoids that
unnecessary copy. A [fresh checked rebuild](evidence/bootstrap-base-preservation.json)
confirms unchanged Base bytes, inode, mtime and ctime, and exactly the same second
API hash. Final native/JS self-emission uses a separate immutable Base/effect
snapshot with the same canonical path on both sides.

## Cache-aware iteration decision

The second native candidate's fresh-process comparison rotates three variants
over two workloads (a tree program and imported foreign code), with three
repetitions each. All 18 compilations have identical emitted bytes within each
workload and pass execution; compiler modules match across variants and all
recorded inputs/tools remain unchanged. CPU 3 is pinned for these samples, on a
shared host, so these medians are local observations rather than universal ratios.

| Workload | Native graph | Uncached JS | Validated-cache JS |
| --- | ---: | ---: | ---: |
| Tree | 1.927 s | 6.718 s | 1.851 s |
| Imported foreign code | 1.892 s | 6.604 s | 1.591 s |

These are whole fresh-process compilation times, including startup and host
work. The native executable's successful checking/emission/C-build phases cost
208.844 seconds in this run. Native has no build-amortization advantage over
cached JS on these small workloads. The design's earlier roughly twenty-case
break-even estimate compared against uncached JS and must not guide normal
cached development. The measured cache preparation was a 120 ms validation/read
of an existing cache, not the cost of creating one after a changed compiler.

This supports the phase 2 priority: use a checked bootstrap and validated Base
reuse for focused semantic work, and schedule larger native/self-hosting proofs
separately. The live pinned TypeScript measurements and larger compiler workload
are recorded separately when complete.

## Self-emission and comparison provenance

The self-host runner now verifies source canonical identity, Base, runtime,
initial/stage compilers, the actual driver and its consumed helpers before and
after every stage. Eight focused tests cover successful proof/resume, Base and
helper drift, source symlink retargeting, old-format resume refusal, preservation
of an existing proof, and refusal to reuse a tainted stage. Reports created by
the earlier runner remain earlier evidence; their missing provenance is not
retroactively inferred.

Paired native fixtures must use the selected main, canonical pinned Base and the
reference filesystem's dependency identities. The adapter rejects module/asset
remapping to another physical file, even with identical bytes, while allowing
legitimate symlinks and unchanged missing assets. This restriction belongs to
controlled comparisons; the standalone graph host retains its explicit remap
capability.

## Live pinned reference baseline

The [fresh upstream frontend sweep](evidence/reference-full-frontend.json)
observed all 1,378 fixtures in both parse and check lanes (2,756 probes), with no
input/tool drift, crashes or timeouts. All 919 positive fixtures pass both lanes.
Among 459 negative check observations, 457 reject (182 parse, 274 check, one
compile) and two accept at checking because their required rejection belongs to
a later compilation gate. There are three exact check-oracle failures: the
template-cycle diagnostic includes different context, and the two deferred
gates are `io/main_foreign.bend` and `reg/array_open_element.bend`.
This reference uses the pinned exported TypeScript APIs and the documented
CLI-policy adapter; it is not the unavailable Bun CLI.

The [fresh runtime pairs](evidence/runtime-live-reference.json) isolate the host
corrections using the pre-frontend-repair compiler API. Both live compilers pass
`borrow_fork_hold` in the interpreter and JS lanes with the same 4 MiB child
stack. Pinned upstream's native `stack_fault_trap` crashes without output; the
corrected port prints the fixture-required memory-fault line and exits 1. That
intentional runtime bug fix is fixture success but not exact upstream parity.
The paired report correctly remains unsuccessful as a joint exact comparison.

A later provenance audit found that older bootstrap reports recorded the pin and
source/API hashes without proving the consumed upstream checkout was clean at
build time. New builds enforce clean pinned tracked compiler sources, capture
canonical identities and hashes for the upstream compiler/Base, actual build
tools, manifest, captured modules and assembled source, and verify them before
and after emission. Drift prevents publishing the staged API. Three temporary
Git-repository tests cover clean capture, dirty upstream and input/canonical
identity drift. Earlier reports are not retroactively given this provenance; a
fresh final-source rebuild will establish the strengthened evidence separately.
