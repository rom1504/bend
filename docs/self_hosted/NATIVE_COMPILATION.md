# Native compilation and a fast editing loop

The default self-hosted package is Phase82 B2: the Bend compiler compiled by
itself. It checks and compiles Bend to JavaScript or C without a TypeScript
fallback. B1 remains the checked development-build stage. Use
`node selfhost/tools/development/release.mjs --verify` from the repository root
to check the installed source/package bindings.

For ordinary one-shot execution, use the existing CLI:

```sh
node --stack-size=4096 --max-old-space-size=1024 selfhost/cli.mjs program.bend --run
```

For repeated **Bend-to-C emission**, keep the compiler process alive:

```sh
node --stack-size=4096 --max-old-space-size=1024 selfhost/tools/native-session.mjs
```

Write one JSON request per input line, keeping stdin open between edits:

```json
{"id":"edit-1","input":"program.bend","output":"build/program.c"}
{"id":"edit-2","input":"program.bend","output":"build/program.c"}
```

Paths are relative to the process working directory. Create the output directory
first. Each response is one JSON line containing the same `id`, status,
diagnostic/report information, request duration, RSS and `recycle`. Successful
responses include the output path, C byte count and SHA256. Only successful
compilation replaces the output; errors preserve an existing file. The output
must end in `.c`. The session emits C; compiling/linking it and executing the
program remain separate existing native-build operations.

Source graphs are discovered and checked on every request. Editing a source or
an import does not require restarting. Ordinary semantic errors allow the next
request; an unexpected host/protocol error terminates the session. Compiler,
runtime, Base or bound driver changes require restarting. The tool hashes their
identities before/after each request and rejects source/compiler output aliases.
No generated-program cache, custom compiler algorithm or TypeScript fallback is
introduced by this JavaScript process wrapper.

Requests are serial. Restart when the response has `recycle:true`, at most128
requests or when post-request RSS reaches1GiB. This is a recycling threshold,
not an operating-system memory limit; the Node flags bound heap/stack and the
benchmark guard additionally bounds the process tree. A source change racing
with compilation has the same limits as the ordinary file-based driver; the
session does not add a filesystem snapshot transaction.

The module also exports `createNativeSession({maxRequests, rssMiB})` for callers
that need the C string directly. Create it in a fresh process, then await
`session.compile(inputPath)` sequentially. Start a new process after compiler or
Base replacement, not merely a new session object in a process holding old modules.

## Measurements and admission rules

Phase82 removes two fixed costs from native requests: rescanning the canonical
C runtime template and recomputing a source binder bound after constructing its
mirror index. The [implementation report](../../implementation/phase82/README.md)
records1.673× B1/1.328× B2 upstream on the three-source loop,5.1%/6.2% less
request time than paired Phase78. The small/functions65 held-outs use20.7%/15.1%
less B2 time. Complete C/JS output identity preserves execution behavior. The compiler algorithms remain
in Bend. Public raw APIs and custom runtimes retain their ordinary checks.

### Canonical template artifact

`selfhost/src/runtime/native/runtime-template.json` is generated data. Its five
chunks come from the Bend function `ne_runtime_prepare`, using the same marker
scanner as ordinary emission. The driver checks both the artifact digest and
runtime digest before transporting those chunks. Missing or changed assets use
ordinary rendering. Marker-sensitive prefixes/payloads retain sequential
substitution, and all rendering decisions remain in Bend.

After intentionally changing the C runtime, generate a new artifact with a
checked development attempt:

```sh
node --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/development/native-template.mjs \
  ATTEMPT/attempt.json selfhost/src/runtime/native/runtime.c \
  /tmp/new-runtime-template.json /tmp/new-runtime-template-receipt.json
```

Review the receipt, replace the canonical artifact, and update
`nativeTemplateSha256` in `selfhost/tools/typed-driver.mjs` to its recorded
artifact hash. Rebuild and qualify the compiler/driver together. The tool refuses
to overwrite its outputs. The receipt identifies the checked Bend producer;
the JavaScript tool does not parse template markers. The release inventory
includes the artifact, so relocation preserves the fast path.

### Historical measurements

Phase78 fresh C requests take1.732× upstream with B1 and1.382× with B2 on the
three-source loop:8.2%/5.6% less time than the paired Phase77 compiler. These
clocks exclude imports, explicitly prepared Bend Base, Clang and execution;
upstream checks Base inside its request. Non-IO held-outs improve less, about2–4%
for B1 and0–2% for B2. No cold parity or universal ratio is claimed.

The earlier Phase77 five-source warm-session result is historical: approximately
1.10× upstream with both processes reused. It was not remeasured in Phase78.
The installed session's correctness/edit/error controls were rerun.

Phase78 retains normalized annotation heads and field quantities for checked
layout validation. A whole-runtime-closure escape index permits omitting curried
factories only for exactly saturated non-bang uses; all value/partial/overapplied
uses keep the closure ABI. Saturated intrinsic calls use existing native operation
lowering, so their now-unused public entries can be omitted under the same private
checked-host permission. Observers retain original erased bodies through static
preparation, avoiding repeated erasure. No cross-request native cache is shipped.

Scalar Word patterns are compacted into private low-bit rows after typed erasure;
alpha-equivalence guards default sharing and escaping tails retain materialization.
An admitted worker plan permits omitting redundant generic host bodies only on
the checked no-bang path. Raw/bang/device fallbacks stay available. These changes
trade a measured1.8% aggregate native-execution slowdown for substantially lower
compiler request time. Expression regresses14.25% and Array.map5.04%.

Phase78 execution is effectively unchanged versus Phase77 on12 families; see
[all metrics and tradeoffs](../../implementation/phase78/README.md),
[the historical Phase77 report](../../implementation/phase77/README.md),
[native ownership rules](NATIVE_OWNERSHIP_FACTS.md) and
[fast-loop methods](../../selfhost/tools/performance/phase77/README.md) before
changing admission rules or comparing numbers. Keep cold compilation, warm
requests, Clang time and generated-program execution as separate measurements.

## Retained request architecture

The checked driver shares an immutable indexed context between annotation and
runtime-layout validation. It then asks Bend to create an `NR_Request` containing
the source context, ordered reachable names, erased ordinary bodies, foreign
paths and foreign scope. This is a request-local product, not a cross-request
cache. Foreign wrappers retain their fresh-ID-dependent construction. The source
book remains available for ownership and binder-range validation; generated IDs
must never substitute for those checks.

Static constructor preparation consumes the retained erased bodies. The same
private definition fact can retain runtime arity, with an explicit presence bit.
Only the owned checked request computes it in advance. Raw static preparation
adds no telescope evaluation, preserving raw demand/error behavior.

`NF_Plan` chooses and admits ordinary/product workers before generic lowering
when the checked representation certificate permits it and the reachable program
has no bang calls. Generic scheduler bodies and device fallbacks remain where demanded. Phase75
removed omission of redundant host bodies for generated-program regressions;
Phase77 restores this permission on the checked no-bang path under explicit
user authorization for that measured tradeoff. Bang/raw paths retain their original error
order: failed generic lowering returns before optional worker planning.

Private constructor lookup shares a depth-first, first-winner index across the
request. Static preparation retains that index. Variable-use analysis has a
separate compact U32 set, with exact full-width keys and no allocation on repeated
insertion. It retains Var-as-leaf behavior even for malformed raw terms.

Product-route retry retains prior code unless that function references a
withdrawn product signature. Constructor facts and other lowering inputs do not
change in this retry. Observer routing and worker admission rules are preserved.

Trust reporting is independent of optimization. One Bend result supplies both
the verdict and ordered unsafe-definition names. A fully completed safe dependency
walk may share its safety facts with subsequent roots in the same immutable
book. A walk that encounters unsafe code contributes no such facts. Public
`driver_report` and `driver_bad_names` remain available as differential oracles.

## Diagnosing compilation latency

Compiler hosting and the emitted program target are independent. The installed
B2 runs as JavaScript even when emitting C. The [Phase86 native-host investigation](../../implementation/phase86/README.md)
also builds the current Bend source as a native executable through pinned
upstream TypeScript C emission and Clang. That executable runs compiler algorithms
in Bend without Node or TypeScript at request time. It is an experimental native
B1, with a restricted IO entry; it is not the installed CLI or native B2.
Its [methods](../../selfhost/tools/performance/phase86/README.md) separate Base
preparation, prepared requests, whole processes and compiler-image build cost.
Read those limits and results before treating native hosting as a speedup.

The [Phase85 V8 investigation](../../implementation/phase85/README.md) measures
the JS-hosted compiler's native-emission latency separately from Clang and native
program execution. Much first-request CPU is V8 compiling the compiler itself.
The [diagnostic commands](../../selfhost/tools/performance/phase85/README.md)
provide clean, trace, CPU, bytecode and thread-CPU modes with exact-output checks.
An explicit two-CPU development configuration cuts B2 request time39% in the
four-source screen; upstream gets the same hardware and also speeds up. Keep this
hardware result and repeated-process timings separate from qualified cold metrics.
Production flags and compiler images remain unchanged.

## Historical Phase76 decision

The following records the earlier exact-output selection, superseded by the
explicit Phase77 tradeoff above.

Phase76 evaluates compact scalar decision rows and explicit lazy native checks.
The latter avoid metadata construction for ordinary definitions/non-call heads,
and stop representation scans once eligibility is decided. Native admission and
certificate rules are preserved. Bend Boolean argument evaluation made the old
combined expressions perform work even when its result was no longer needed.
See the [Phase76 report](../../implementation/phase76/README.md) for selected
measurements and qualification.

Scalar decision rows are retained as an unpromoted experiment outside the active
manifest. They substantially reduce compilation time and C size, but generated
Tree and Array.map executables regress by roughly 4–5%. Smaller generated code or
identical hot instruction sequences do not establish equal execution speed.
The selected exact-output path keeps the existing representation and output.
