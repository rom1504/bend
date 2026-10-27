# Phase145 independent evidence review

Bounded read-only audit, 2026-10-27. No compiler or generated target was run.
The reviewed compiler is final04 source `865cff6a…745c4ed`, with its checked
JavaScript API and qualified native N2. This review covers the strict repeated
verification witness, the completed clean Lexer pilot, and the completed small
native operation/stage observations. Later warm-process, other-family clean and
upstream runs require their own completed receipts; no result is inferred from
a pending or failed run.

**Conclusion:** the strict witness supports a real repeated-input verification
claim, and the clean pilot supports its narrowly stated workflow comparison.
No blocking semantic defect was found in these observation methods. The most
important limits are that structural content is not an alias-topology
certificate, diagnostic counters are not execution-time shares, and the
same-source JavaScript/native comparison is not an upstream compiler ratio.

## 1. Repeated raw verification: what the witness establishes

Methods reviewed:

- `selfhost/tools/performance/phase145/execution/verified-inputs-v01.mjs`
- `selfhost/tools/performance/phase145/execution/prepare-verified-v01.py`
- `selfhost/tools/performance/phase145/execution/run-verified-v01.py`
- the underlying `prepare-v01.py`, `hosted-v01.mjs`, and actual selected API
  definitions of `p112s_verify`, `p114s_open`, `p113a_verify`, `p113e_verify`.

The prepared derivative preserves the generated computations and adds entry,
exit and fingerprint calls. Removing the recorded additions reproduces the
already reversible counter derivative, whose own reverse operation reproduces
the exact checked API. Preparation verifies those equalities. The runner pins
the methods, source/API, runtime/tool and input/output identities before and
after execution and requires the complete ordinary QBE oracle.

The generated `p112s_verify` is synchronous:

```text
p111_first(run_loop(p111_verify_program(program)),
           run_loop(p112s_image_error({program, nodes})))
```

Both argument computations finish before the function returns. Therefore the
`finally` fingerprint is after the raw-program and static-image checks, rather
than after merely constructing a deferred trampoline. The instrumented caller
scopes similarly enclose the observed calls in the actual generated program.
The source implementation has the complete static bundle as its sole argument;
its fixed helper implementations use that data rather than a request-global
mutable validation context.

The completed Lexer witness is:

`selfhost/build/phase145/execution-verified01/lexer-00-js-counts/observation.json.verified-inputs.json`

SHA-256 `f57225f6a081d64ba50b14885346ab3294f01bbdd810716ccb872f681402e315`.

| Invocation | Recorded call path | Root identity | Structural objects |
| --- | --- | ---: | ---: |
| First |`p114s_open`|1|27,479|
| Second |`p113a_verify → p113e_verify`|1|27,479|

All four before/after fingerprints equal
`56e41a1fc0620c83b54a65dec3ab9afb93e4f59428f9b68dc3ca42a8c80e1ebe`.
The ordinary request exits successfully, produces no stderr, and exactly matches
the577,601-byte QBE oracle `7020b75d…57ce`. The complete supervisor receipt is
`selfhost/build/phase145/execution-verified01/report.json`, SHA
`6d8f2dcbfe9c65fa6ea0923f8ef77d8431623620b01835eb2b0f0de38f986911`.

This is stronger than two function-entry counts: it observes the **same root
object and the same complete structural contents at both verification calls**.
It confirms the duplicate traversal predicted by the source audit for this
successful Lexer request.

### Limits that should stay attached to the claim

The fingerprint traverses the complete own data values, uses explicit primitive
type tags and object-kind markers, distinguishes negative zero, memoizes
completed DAG nodes, and rejects unsupported scalar values, accessors, symbols,
cycles and non-data ordinary-object prototypes. Array elements/length are
validated; array prototype identity and property attribute flags are not part
of the content digest. These do not undermine the observed ordinary Bend data
input, but the method should not be described as an arbitrary-JavaScript-object
identity certificate.

Its Merkle content hash deliberately does **not** encode child alias topology.
Equal children substituted with equal copies can retain the same hash. The
reported object count helps describe the observation but is not included in
`unchanged`; root identity is tracked separately. Before/after equality also
cannot rule out transient mutation and restoration between observations.
The selected persistent pure verifier gives independent source-level reasons
not to expect such mutation; the hash alone does not prove purity.

The witness records completion in `finally`, not the returned verification
string. Thus a standalone `completed:true` row is not a success certificate.
Here the successful independently checked complete output and selected caller
logic provide the surrounding acceptance evidence. A future reusable validation
receipt must bind the actual result, source/runtime epoch, input and required
dependency context explicitly.

This is one finite hosted observation. It does not prove all-input redundancy,
native heap identity/lifetime safety, or that skipping the check is profitable.
No check was skipped and no validation token was implemented. In particular,
it does not justify skipping final verification of changed direct functions.

## 2. Clean execution comparison: native versus the same Bend implementation

The completed two-pair Lexer pilot,
`selfhost/build/phase145/execution-pilot01/report.json` (SHA
`69b0ec72f1eb08cad066a104705a4de1b354bd5a6b8260fc67c3bb0fb53cb651`),
uses the same final04 source, exact source/Base/carrier inputs and complete QBE
oracle. Pair order alternates. Its median whole-child times are:

| Engine | Seconds |
| --- | ---: |
| Checked Bend compiler API hosted by Bun |7.441962|
| Qualified direct-QBE native compiler N2 |1.187428|

The geometric mean of paired native/JS ratios is0.1595596, approximately6.27×
faster native execution for this workflow. Both pairs and all products pass.
Two pairs provide a useful large-effect screen, not a confidence interval or
full-corpus ratio.

The JS role is **our compiler written in Bend, compiled to JavaScript**, not
the upstream TypeScript compiler implementation. Therefore this result neither
establishes upstream parity nor contradicts a remaining upstream gap. It does
show that moving this same implementation wholesale back to the measured
JavaScript path is not a demonstrated speed fix.

The clock is process creation through exit. JS includes importing its API,
observer timing/metadata calls, encoding/writing cursor pieces and natural GC;
native includes its actual CLI IO, reference counting and teardown. Source and
Base file reads are included. API/image acquisition and parent authentication
are excluded. Both use prepared Base, fresh processes, the same CPU lane, and
unflushed OS caches. No forced final JS full collection makes the engines'
reclamation mechanisms identical. These are documented execution workflows,
not a perfectly isolated instruction-selector treatment.

The JS import is about0.206s in the observed pilot, so import alone cannot
explain the multi-second difference. However, allocating the remaining gap to
specific representations, recursion or generated dispatch requires the actual
stage/call-path evidence. Warm-process effects must be measured separately;
the incomplete first warm receipt cannot serve as a successful result.

## 3. Native runtime counts: useful categories, not a cost model

The completed counter observation relinks the exact final04 program object
against the diagnostic runtime instead of recompiling the compiler. Off/on
requests and independent controls require the frozen full outputs. The source,
object, selected serial-runtime policy and attribution map are bound by the
receipts. See `research/phase145/native-counts.json` and
`selfhost/build/phase145/native-observe02/report.json`.

The counts establish large real operation traffic on three small complete
requests:7.78–23.68 million allocation calls,5.86–21.81 million takes, and
9.54–33.21 million register words copied. Whole-request allocation/free counts
and requested/free word totals balance; register-clear counts are zero.

The warranted interpretation is that ownership, representation and transport
still perform substantial work after serial reference-count optimization.
It is **not** that every take rebuilds a node, every keep changes a count, every
sink traverses a large object, or every copied word is avoidable. These are
event definitions, not one interchangeable unit of work. Class-rounded requested
allocator words are not peak memory, unique bytes or lifetime attribution.

The36 selected prepared-Base decoder contexts have exactly matching non-refill
counts across the three inputs, including4,501,818 allocations. This is a useful
fixed-work witness, but the selected owner set is posthoc and not an exclusive
Base phase. Context is active dispatch ownership, not a logical call stack or
the allocation origin of an object later destroyed. Inline/private operations
can bypass public runtime hooks. This counter interface therefore cannot supply
a complete String-character or query-probe census.

The separate exact-stage capture puts actual Base/carrier preparation at about
0.232s on each input. Its share is large only because the inputs are small.
The retained final03 full-source Base interval is0.256s. Removing that category
would improve short iterations but cannot plausibly turn a231s full compiler
request into50s. That is a concrete example of why operation fractions should
not be extrapolated to the large-build target.

Stage marker timing and32ms samples are separate instruments. The short runs
have156/243/51 samples, below the500-sample threshold, so do not rank tiny leaf
fractions confidently. The optional final-verifier marker is nested in observer
work, and its absence in Lexer/closures does not mean there was no ordinary
independent verifier. Physical, source-owner and stage views overlap.

## 4. Relation to upstream and architecture conclusions

The reviewed upstream method correctly distinguishes a different compiler
algorithm and backend: upstream loads/checks source Base and emits C; this
native path decodes prepared Base and emits QBE. Upstream's checker produces a
checked runtime term; its emitter still runs to a fact fixed point. A future
completed comparison must keep those work differences and the external
Clang/QBE machine-build boundaries visible. Internal entry counts across these
implementations are not directly comparable semantic operations.

The strongest conclusions currently warranted are:

1. **Measure one immutable-context reuse boundary next.** The Lexer witness
   establishes actual repeated raw/static verification, not just similar names
   in the call graph. First isolate its native cost and prototype eliminating
   only that repeated preparation inside the private request, retaining the
   independent final validation of actual transformed output. Require the
   original full diagnostics, body/context invalidation and complete bytes.
2. **Retain typed local identity across complete computations.** The architecture
   trace and native operation evidence support a producer→schema→flow→render
   experiment, including conversion and teardown. They do not yet supply a
   numeric whole-build speedup estimate. The prior compact-verifier result
   remains a slice result with a crucial generated-worker admission confound.
3. **Separate small-loop and large-build objectives.** Fixed Base preparation
   is a credible small-request target. Distributed raw lowering, verification,
   registry and rendering dominate larger work. Neither needs an additional
   backend to test the next hypothesis.

Claims not supported by this evidence include "native execution is the principal
reason for the upstream gap," "allocation volume explains the gap," "the final
verifier can be removed," "every repeated term object is redundant work," and
"a generic cache or universal IR will give a specified multiplier." Preserve
the cheap falsifiers and negative findings before broad implementation.
