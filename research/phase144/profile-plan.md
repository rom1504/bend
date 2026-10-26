# Phase144 residual profiling and exact stage boundaries

The purpose is to select expensive categories of compilation work on the actual
qualified Phase143 engine, before another large optimization campaign. The
unchanged input is Phase142 `indexed-source02/compiler.bend`, SHA256
`15f5cada2710119cce19a0cfe961c21f61edc5f0b048f90359090a0c1817dac1`.
Its115,909,112-byte QBE oracle is
`selfhost/build/phase130/p142-indexed-emit01/program.ssa`.

The profiled compiler is qualified Phase143 N2, SHA256
`023ccf1acf52e71cb9578c4ed878ccb4a50a61c28375e3f8b0a54c885736c83b`.
Its own compiler QBE is a different116,477,541-byte artifact: do not confuse the
executable's owner-map input with the request's output oracle. N1/N2 object bytes
match, but their ELF hashes differ. The296.541-second clean observation belongs
to N1, so no fresh N2 clean timing is claimed.

## First capture: ready independent residual information

`selfhost/tools/performance/phase144/profile/prepare.py prepare --out FRESH`
materializes metadata and parses the actual current QBE owner map. It runs no
target. The coordinator executes `selfhost/build/phase144/profile01/jobs.json`
serially: link the retained object with the authenticated Phase131 diagnostic
runtime, seal the identity manifest, run one32ms capture, then use unchanged
generic attribution and timeline tools offline.

The corrected Phase127 CFI sampler and exact libc unwind table are reused.
Counter collection remains disabled; physical leaves, active Bend dispatch and
eligible physical callers are distinct views. Existing complete-output/status,
zero-loss, main-thread coverage, handler and delivery checks remain active.
CPU3,3GiB tree RSS,16GiB free-memory floor and256MiB per-file caps are explicit.
The compiler's source, generated QBE and production runtime are unchanged.

This capture has completed successfully. See [residual-profile.md](residual-profile.md)
and its JSON for exact evidence:10,083samples, zero loss and99.585% main-thread
coverage. Ordinary diagnostic child time324.306s is not clean request latency.
The profile validates that old occurrence and visited-name work fell sharply;
remaining named costs alone do not establish a sixfold path to50s.

## Improved capture: real phase boundaries, not inferred windows

The optional `stages-v02.py` prepares a tiny diagnostic runtime delta and relink
of that same retained object. The existing frozen CFI sampler gains only one
exported function: an atomic read of its delivered-sample count. Its signal
handler is byte-unchanged. At actual direct dispatch boundaries, the runtime
records monotonic wall, process CPU, thread CPU and delivered-sample ordinal.
This provides exact stage entry clocks and ordered sample bins without estimating
boundaries from ordinal×period or aligning unrelated JS stages.

The runtime writes `samples.txt.stages.json` alongside the generic capture,
using the existing sample path. No target argv, stdout, compiler algorithm,
checker, final verifier or production selection changes. It allocates no state
per dispatch and adds no clock calls to the signal handler. The static FID map
and linked addresses are authenticated against the current compiler object.
Diagnostic overhead is real and must be measured before treating clocks as clean.

The main sequence covers Base, parse/load, checker/publication, report,
eligibility, context, annotation/reach, layout, erasure, static preparation,
raw generic/private lowering, initial optimizer, initial independent verifier,
observer discovery/composition, output opening, registry and first render drain.
The remaining tail combines rendering, output and runtime teardown through the
milestone exit hook. It is not exclusive emitter time.

There are22 required unique entries plus the explicitly defined **first entry**
to render drain; all later drain invocations are counted and permitted because
this function is the output loop. Missing, duplicated or reordered required
markers reject the stage interpretation. Unknown/private/inlined boundaries are
never invented. One sample at each interval edge is excluded from histograms
because clock reads and ordinal reads are not atomic with signal delivery.
Unknown sample contexts remain in denominators. Less than500 samples or failed
quality checks leave distributions descriptive, with no quantitative CPU estimate.

## Preserved first failure and its source-level resolution

`stages01` built and emitted exact Lexer output, but the stage gate correctly
rejected a missing `p126bp_complete` entry. Other mandatory entries were each
observed once; render drain ran981 times. This was not an optimizer correctness
failure. Source inspection shows that the non-flat/non-product path legitimately
uses `p118b_compose`, so `p126bp_complete` is not a universal final-verifier entry.
Frozen v01 methods and failed evidence are retained.

`stages02` keeps observer composition plus selected final admission as the common
required interval. It records `p126bp_complete` separately: exact FID/address,
all invocation counts and up to eight individual entry clocks/ordinals. If one
entry occurs between observer discovery and writer entry, the report exposes a
**nested** final-verification interval. If absent or repeated, it makes no isolated
final-verifier timing claim. Nested intervals must not be added to their parent.
This is explicit branch-sensitive attribution, not silently allowing missing or
duplicate required stages.

## Execution gates and cost

Prepared frozen job list: `selfhost/build/phase144/stages02/jobs.json`.
Only the coordinator runs it, serially on CPU3:

1. Compile the small diagnostic sampler/runtime and relink the retained object.
2. Seal the actual build products into the manifest.
3. Run sampled Lexer with its independent whole-QBE oracle (35s target cap).
4. Run `stage-report-v02.py` offline; stop if marker/output/address gates fail.
5. Only after that gate, run the unchanged full request (600s target cap).
6. Join stages, actual ELF, exact output, sample quality and phase distributions.

One successful full extended capture should replace further unstructured profile
runs for this decision. It is not a reason to repeat full native qualification:
compiler instructions and semantics have not changed. Changes to actual compiler
algorithms require their own finite, exact-product and qualification gates.
