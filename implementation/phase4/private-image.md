# Private compiler image

The public generated JavaScript ABI exposes mutable `G` function objects. Its
`.code` getters, partial applications and global rebinding are observable, so an
unconditional positional call or primitive expression cannot replace a public
call. The Phase3 scalar counterexample remains a failing public transformation.

This experiment creates a different, **worker-private compiler image** from the
same checked, self-emitted compiler. Its only external operation is the existing
host `inspect` request/result contract. A request contains an absolute source
path, a parse/check/compile/library mode, and an optional report flag. It cannot
contain compiler graphs, callbacks, global registrations or function objects.
Every request runs in a fresh Node process. The worker returns ordinary JSON and
an emitted-source file; emitted programs retain the unchanged public runtime.
This is not a drop-in replacement for applications importing the public H module.

## Isolation and calling convention

The private module has a fixed host export list from the checked seed compiler
(the initial experiment used its matching checked integration report). It removes the live `G`, generic `call` and `list` exports. A frozen inert
`G` marker retains the existing host's positional-ADT detection, while `ctor`
remains internal to that trusted host's ABI conversion. Neither is exposed by
the request protocol. After registrations finish, global function records,
bound-argument arrays and the global table are frozen.

Known literal `fn(n, function(a){...})` definitions with positive arity receive a
second positional worker. A saturated call invokes that worker directly and
forces its result. A saturated tail call creates a private trampoline record,
which the existing force loop resumes without generic application or argument
copying. This retains bounded tail stack usage. Higher-order calls, partial and
overapplication, zero-arity factories, explicit environments and unsupported
function bodies retain the original path. Nested function parameters retain
their own argument scope. The emitter's argument expressions stay in order.

A separate scalar mode specializes only retained runtime primitive definitions.
It verifies the original runtime implementation's exact fingerprint and excludes
subsequently overridden names. Primitive return values still pass through force
for ordinary calls, including malformed values that return trampoline records;
tail results are forced by the enclosing original trampoline. There are no
public property guards: the globals are genuinely private.

The reason skipping `get` and function-property reads is valid here is the
absence of a route to install a getter, rebind a global or supply a callback
within the worker. Source programs are parsed, checked and emitted as data; the
worker never executes their emitted JavaScript or interpreter/IO entry. Host
prototype mutations happen in another process. The request validator rejects
accessors, proxies, function values and unknown fields without invoking hooks.
The dedicated process is a compiler API isolation boundary, not an OS sandbox
for arbitrary executable plugins. Artifact hashes are verified before and after
every request.

This remains generated-code specialization for a causal experiment. A production
implementation would need an explicit compiler-owned image mode in the Bend
emitter, or an equally explicit checked build specialization with this private
contract. It must not quietly replace a public library artifact.

## Reproduction and gates

From `selfhost/`, run the focused tests directly (so the test count is visible):

```sh
node --stack-size=4096 tools/performance/phase4/private-calls.test.mjs
node --stack-size=4096 --max-old-space-size=4096 \
  tools/performance/phase4/private-benchmark.mjs CONFIG.json NEW_DIRECTORY \
  > LAUNCH.stdout 2> LAUNCH.stderr
```

The benchmark freezes the actual H/B1 source identities, host helpers, worker and
transform inputs. It compares untouched public H, the private boundary-only
control, private positional calls, private scalar calls and their combination.
Each has an independently checked and hash-recorded Base cache. All requests run
serially on CPU0 in alternating original/reversed variant order. Tree and list
sort must emit identical JavaScript and execute with the expected output; the
bytes-operations rejection must retain the exact complete host observation.
Statistics are withheld if any variant fails a workload's correctness gate.

The initial focused gate passed four tests covering numeric corner cases,
partial/overapplication, zero-arity initialization order, nested argument scopes,
100,000 tail steps, overridden primitives and malformed bounce results. It also
reproduces the original public `.code` getter exception and verifies that the
private transport rejects hook-bearing inputs without touching their hooks.
The timing evidence below comes from retained controlled reports, not helper
profiles or rewritten-site counts.

## Recorded controlled results

The initial [45-sample matrix](private-initial.json) completed at 14:33 UTC,
before the later shared-host resource incident. The call/scalar combination
improved tree emission from 3.088 to 2.695 seconds and list sort from 6.391 to
4.973 seconds. Positional calls alone were inconsistent, so they are not credited
with the whole gain.

The next attempt overlapped the 14:39–14:57 resource incident. It retained two
actual deadline failures and `complete:false`; **all of its timing conclusions
are invalidated**, including otherwise passing rows. No timed subset was rescued.
The unchanged clean rerun passed **54/54** exact observations, emitted-byte checks
and applicable program executions. Its [complete evidence](private-refined.json)
records the separate ablations and their tool snapshots:

| Request median, milliseconds | Public H | Boundary only | Calls + scalars | + private projections | + private exact apply |
| --- | ---: | ---: | ---: | ---: | ---: |
| Tree emission | 3060.94 | 3071.44 | 2520.71 | 2436.79 | 2266.46 |
| List-sort emission | 5626.76 | 5481.61 | 4673.19 | 4326.81 | 4256.95 |
| Exact bytes-ops rejection | 2170.96 | 2154.19 | 1770.79 | 1707.64 | 1621.34 |

The full private candidate is 1.35×/1.32× faster on these two successful requests.
Process-wall medians are also retained; they include startup and identity work
and show smaller improvements. This does not establish a full self-compilation
speedup or a public-runtime optimization.

Private projection specialization recognizes only the exact KTerm/KDef accessor
bodies. These records come from the checked compiler/parser or trusted host ABI
encoder, never from user-supplied JavaScript objects. Saturated accessor calls
can therefore read a single positional field without project, copying or force.
The argument still evaluates once. An early tokenizer test caught a mistaken
rewrite of the `.a` property name; the corrected tokenizer and its regression
passed before this measured candidate was generated.

The private exact-application path brands internally allocated function records.
An unbound exact call can borrow its argument array without the original copy.
The array is fresh or an immutable constructor field array, and the checked
compiler does not mutate it or let it escape to user callbacks. Other values,
partial calls and overapplication retain the original path. This ownership claim
is specific to the isolated inspect image; the ordinary public `apply` copying
contract is unchanged and remains covered by its existing regressions.

A separate optional constant experiment requires an exact token-normalized proof
of the closed `missing → atom → kt` constructor-only bodies. It publishes a memo
only after forcing the complete result. Arbitrary fn0 factories are excluded.
Seven focused tests now pass, including proof refusal after an injected effect,
unchanged factory order, the old public getter counterexample and private
transport rejection. The raw failed tokenizer check is retained alongside its
subsequent passing checks; no failed test was relabeled as a pass.

## Compiler subset and constant result

The final prototype [48-sample matrix](private-core.json) includes an actual
60,909-byte, 312-declaration compiler subset assembled from the unchanged core
term, index, normalization and graph modules. Each variant compiles that source
as a library; all resulting bytes match, and the library loads successfully.
This is stronger than an arithmetic microbenchmark and smaller than full compiler
self-emission. It is not reported as a whole-compiler speedup.

| Request median, seconds | Public H | Boundary only | Private calls/projections/runtime | Plus proven `missing` memo |
| --- | ---: | ---: | ---: | ---: |
| Tree emission | 2.957 | 2.928 | 2.111 | 2.095 |
| List-sort emission | 5.384 | 5.310 | 4.023 | 3.776 |
| Exact bytes-ops rejection | 2.054 | 2.062 | 1.516 | 1.505 |
| Compiler-core library | 52.212 | 55.504 | 36.013 | 34.651 |

All **48/48** observations passed. The strongest candidate improves this compiler
subset by **1.51×**, tree by **1.41×**, and list sort by **1.43×**. Its compiler-core
process-wall median is 35.938 seconds versus 53.452 seconds for public H. The
constant-only increment is modest: about 3.8% on the core subset and 6.1% on list
sort, with nearly flat tree/rejection results. No arbitrary zero-arity memoization
was inferred from this result.

A bounded, warmed list-only profile of the private calls/projections/runtime
variant completed in 6.2 seconds without the earlier resource incident. It still
attributes 26.3% of exclusive samples to `apply`, 11.5% to `force`, and 8.4% to GC.
These are diagnostic shares, not achievable speedup estimates. The earlier public
profile used tree, so subtracting the two percentages would be invalid.

## Canonical private compiler workflow

The independently usable implementation is now
[`selfhost/tools/private-compiler`](../../selfhost/tools/private-compiler/README.md).
It extracts the proven tokenizer/runtime fingerprints and transformations into
canonical files; the build/run path has no dependency on disposable rapid tools.
The first finalized release image is
`selfhost/build/phase4/private/release3`. Its image hash is
`1905c283551d4ad93c129549f8c540d8d21b47eb0486d88036f0afa9a0d4f9ab`,
exactly the winning prototype bytes. Its builder consumed the genuine completed
Phase3 fixed-point proof and checked the source, canonical Base, initial compiler,
all four host helpers, original host, runtime, both successful checked emissions
and their chain/equal hashes. It did not manufacture a bootstrap sidecar.

The build took **1.131 seconds inside the tool**, **1.217 seconds including Node
startup/process exit**, on CPU0. This is a specialization of an already proven
compiler; it does not include producing that checked/self-hosted compiler. An
explicit experimental mode accepts a completed, input-verified checked stage from
a pending proof but carries `checked-stage-proof-pending` through its manifest
and every result. It cannot be mislabeled as a completed fixed point.

Only the frozen host's cache-root declaration is rewritten. Compiler algorithms
and public program emission are unchanged. The CLI accepts JSON paths/modes,
verifies immutable image artifacts before/after, hashes exact bytes consumed by
the host's existing file transport, retains lexical/canonical resolutions, and
rechecks consumed inputs again before publication. Results live in a new directory;
source/prior-result overwrite is refused. Output is initially pending and is
renamed only after successful checked emission and final identity checks. A
compiler rejection remains a complete infrastructure run with the original
`status`, `phase`, `checked`, diagnostic and exit code; it is never counted as an
accepted proof.

The selected final CLI gate passed **22/22** exact public/private observations:
ordinary imports, non-BMP Unicode output, library loading, parse mode, foreign
check/emission, Unicode type failure, syntax failure, TODO rejection and the
existing bytes-operations rejection. A foreign JS sentinel proves that compiler
checking/emission did not execute it. Generated programs were executed only by
the separate validator, where expected. These are selected controls, not full
corpus coverage.

Fifteen named unit regressions pass under both direct file invocation and
`node --test --test-isolation=none`; four additional checks use the real finalized
image to verify timeout-without-publication, existing-directory preservation,
native-mode refusal, and runtime-drift refusal before worker startup. The unit
gate also rejects same-byte symlink retargets, changing repeated reads, appeared
missing inputs, altered pending bytes, false checked flags, output symlinks and
existing publication targets. Test fixtures with synthetic proof records only
exercise the validator; no deployed image uses synthetic provenance.
