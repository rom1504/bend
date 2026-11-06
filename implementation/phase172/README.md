# Phase172 — controlled retry;100s remains unmet

The complete comparison is **181.741→180.667s**, only **0.59% less** in one
matched pair: effectively neutral, not an established speedup. The100-second
objective remains unmet. Installed/qualified Phase170 is unchanged. This campaign tested the actual remaining semantic and runtime
boundaries identified by Phase171 and the bendc comparison, with small falsifiers
before complete compiler measurements.

[Metrics and exact receipts](metrics.json) · [Reproduce](reproduce.md) ·
[Design](../../design/phase172/README.md) ·
[Bendc comparison](../../experiments/phase172/bendc-frontier.md) ·
[Static publication audit](../../experiments/phase172/static-seal-audit.md).

## Completed experiments

| Experiment | Correctness evidence | Result / decision |
|---|---|---|
| Deferred ordered pattern substitutions |20 complete substitution cases,24 complete flattening cases,682,767 loader values, exact2,309,376-byte real-verifier QBE|Hosted full-loader4.967→5.021s: neutral. Do not acquire a full native compiler.|
| Inline cold construction |Exact full-image metadata census|Zero coverage: all703 constructors hot. Reject before acquisition.|
| Inline construction when fields already sealed |Checked API,27 finite controls, two full IR observations, real native outputs|Verifier0.9938×, lookup1.0689× runtime; code grows. Reject as a default.|
| Omit wrappers around immutable static constructors |Independent source/runtime audit; macro-off object exactly equals installed runtime; six ordinary controls pass|Verifier0.9581×, lookup1.0035×. Full compiler0.9941×: effectively neutral; no promotion.|

The short native rows are four balanced fresh-process rounds on CPU3 with exact
independent stdout. They measure those workloads, not full compiler throughput.
The hosted loader row is one shared-process diagnostic observation, not a native
speed claim. The deferred-row plan still scans the substitution chain at each
variable and adds pending-list ownership work; it does not eliminate all repeated
work. A proposed native checker test was cancelled because its actual embedded
inputs contain no relevant pattern matching. Preserving this negative prevented
an expensive but uninformative build.

The inline memory experiment enlarges real-verifier QBE from2,309,376 to2,560,085
bytes and lookup from273,945 to483,914 bytes. Replacing opaque calls with guarded
code therefore did not pay for itself. These are static byte counts, not dynamic
allocation counts. None of these changes was integrated into production.

## Stronger runtime follow-up

`rfc_seal` allocates a reference-count wrapper even for immutable static nodes.
The existing final static verifier guarantees that their fields are immediate
or refer to earlier immutable static nodes. Raw static values are already legal
in keep/drop, shared-child consumption and borrowed reads. Destructive reuse
explicitly excludes static storage. The experiment omits just that wrapper;
ordinary dynamic publication remains unchanged.

This is distinct from cold-constructor analysis, which is refused globally for
the compiler's File effects, and from claiming that all compiler objects are
unshared. It follows a useful bendc contrast: cached literals need no separate
per-publication wrapper. Bendc itself still uses linked code-point Strings; a
claim that its speed comes from packed String storage would be incorrect.

The private runtime is built with the same GCC10 and flags. Its disabled object
is byte-identical to installed runtime`2d078323…`. Both roles link the identical
program object, so small experiments cost relinking rather than full acquisition.
Exact heap allocation histories intentionally differ; no mathematical equivalence,
parallel/GPU qualification or resource-exhaustion timing claim is made.

## Complete comparison boundary

The relinked compiler uses the unchanged Phase171 four-overlay N1 machine object.
Its disabled binary is exactly the original`c354b39c…`. The benchmark remains the
full3,150,535-byte Phase170 source`434edd1d…`, prepared Base, one CPU3 lane and
unchanged target runtime/toolchain. Every complete result must reproduce all
97,488,970 QBE bytes`661b6266…`. Changing the runtime executing the compiler is
separate from changing the runtime of its output programs.

The fresh disabled-runtime full build is181.741s, including QBE/assembly/link;
the candidate takes180.667s. Their overlapping compiler/QBE relays are175.718s
and174.733s. Both exactly reproduce QBE, assembly and object. Whole ELF hashes
differ; no loaded-segment identity claim is made for this pair. The baseline
runs first; this is one observation per role and does not resolve a0.59% gain.
Do not add overlapping intervals or use the earlier188.620s baseline to inflate
this isolated runtime change. This relink adds no new bootstrap generation.

## What actually disappeared, and why it was insufficient

The diagnostic baseline counts only `rfc_seal`, not every possible reference-count
operation. Its programs still produce the full independent expected outputs.

| Complete native workload | Sealing calls | Static wrap requests omitted by the candidate | Share of new seal wrappers |
|---|---:|---:|---:|
| Real verifier |7,147,520|637,184|35.46%|
| Real lookup |26,570,000|770,000|5.23%|

The static requests are only8.91% and2.90% of all sealing calls, respectively.
The remaining work includes dynamic wrappers, retained values, checking,
lookup, transformation and rendering. Removing hundreds of thousands of objects
is real work elimination, but it is not evidence for a large whole-compiler
speedup. Counts come from a separate instrumented baseline; its clocks are not
used as performance evidence. Full-compiler static-wrap counts are unmeasured.

The stronger initial theory—that QBE's opaque memory calls were the main missing
bendc advantage—also did not transfer in this pilot. Expanding them introduced
branches/live temporaries/code size and the lookup workload regressed6.89%.
This falsifies these templates as a default, not every possible ABI optimization.

A further [actual-code audit](../../experiments/phase172/choice-frontier.md)
falsified the idea that ordinary conditional helpers still allocate branch
closures: current closed-selector expansion already emits local branches in the
inspected hot verifier functions. There is no justification for another chooser
pass. Likewise, adding a packed String representation cannot be justified as
copying bendc: bendc uses linked code-point Strings too.

## Decision and next architectural boundary

Keep the Phase171 four-overlay candidate as experimental and Phase170 installed.
Do not integrate deferred rows, guarded constructor expansion or static sealing
based on these results, and do not spend another full self-hosting campaign
trying to qualify a neutral outcome. Correctness evidence is finite; none of
these experiments proves compiler correctness or recursive acceleration.

The next candidate must remove a measured complete producer/consumer boundary.
A specific unproven possibility is immutable record replacement: helpers such as
`k_with_children`/`k_with_span` preserve most fields while replacing a few. Trace a
hot actual caller through generated take/seal/rebuild/drop operations, and test
whether a uniquely owned update or shared copy can avoid reconstructing retained
fields. Require dynamic coverage, alias/static fallbacks, independent outputs and
an actual whole-request ceiling before implementing a broad pass. Existing
destination-passing optimizations may already cover part of it. This is a proposed
falsifier, **not a measured path to100s**. The evidence does not currently support
promising that one remaining optimization can remove80 seconds.

## Cost and retained references

No full compiler source acquisition was needed for the runtime experiment.
The qualified compiler, runtime, manifests and rollback references remain intact.
Early source-check failures are preserved in frontend revisions01–04 and runtime
revision01; source05/runtime02 pass checking. They are not counted as successful
controls. The source algorithms are Bend; host scripts authenticate inputs,
transport output, relink and observe. The existing native runtime remains C.

Twelve explicitly reviewed old completed/rejected artifact roots were archived,
reopened and hash-verified before pruning only selected generated SSA/assembly/
objects. This recovered570.27MiB net. No retained executable, current source,
qualified runtime or active profiling dependency was deleted. All new target
jobs use one bounded CPU3 lane and maintained disk/process guards.


The29 guarded jobs consumed563.670s total (9.39min):365.978s in the two full cold
comparisons,61.772s in successful checked API acquisitions,19.477s in five failed
source acquisitions,72.807s in smaller complete compiler requests, and the rest
in controls, small machine builds, pair execution and preparation. This is target
lane cost, not total elapsed research time or model billing. Agent/billing quota
telemetry was unavailable; no cost estimate is invented. Four bounded agents
provided frontend/runtime implementation, independent audits and storage review;
root owned all29 guarded jobs. No PR comment was posted.
