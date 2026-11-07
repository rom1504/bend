# Phase175 — frontend work reuse and native qualification

**The complete fixed-source build took 185.550→178.937s: 6.612s, or 3.56%, less
time in one controlled pair.** The frontend component decreased 10.56% in its
separate two-round comparison. Native64 passes and all 45 timed-wrapper QBE
products remain exact. The selected changes are integrated in maintained source;
the installed compiler remains unchanged as planned.

[Design](../../design/phase175/README.md) · [Exact metrics](metrics.json) ·
[Receipt index](evidence-index.json) · [Reproduction](reproduce.md).

All selected source, native and public product gates passed. The same-source C
execution comparison hit its
Clang construction budget, so has no execution result. There is no new upstream-parity score,
100-second build or generated-program runtime measurement. The installed compiler
has not changed.

## What we learned

The parser repeatedly requested the same token spelling and constructed the same
lookahead tail while deciding how an expression grows. Two small replacements
share those observations within the decision and leave parsing transitions,
source positions and errors unchanged. Unlike earlier allocation-count
improvements, this removed enough work to appear in a complete native parse/load
measurement on the unchanged 3,150,535-byte compiler input.

The other hypotheses illustrate why complete-component measurement matters:
finite precedence dispatch was neutral; reusing already-established constructor
field quantities during erasure was neutral or slightly worse; delaying further
publication canonicalization was neutral. Replacing quadratic report-name
membership with the existing collision-safe index has a small positive screen,
but no isolated paired confirmation yet. The selected combination improves the
frontend and complete build; this does not isolate each change's contribution.

## Results and measurement boundaries

All source timings use the frozen Phase170 compiler input
`434edd1d56128f9480800573abf8a0ae21d910a547837af089f25cd1d0e89b71`,
prepared Base and the same QBE runtime/toolchain. The executing reference is the
installed Phase171 version published in Phase174, canonical source
`74cd7de3e5076490e20ba0218d4c9254853be72562946b9ef66fed6c10c7a53a`.
Targets run through the root-owned CPU3 execution lane.

| Experiment | Component baseline | Candidate | Interpretation |
|---|---:|---:|---|
| Complete fixed-source build |185.550s|178.937s|3.56% less; one candidate→baseline pair, same streaming reference check and no retained IR.|
| Lookahead plus indexed report names, complete frontend |62.854s|56.219s|10.56% less; baseline/candidate/candidate/baseline, matching full-input observation.|
| Reuse parser lookahead |26.452s|23.062s|12.82% less; one baseline→candidate pair.|
| Finite operator precedence dispatch |26.661s|26.381s|1.05% less; treat as neutral.|
| Checked field-quantity reuse |60.509s|61.085s|Separate full-frontend screen; do not select.|
| Deferred publication flush |60.509s|60.297s|Separate full-frontend screen; neutral.|
| Indexed report-name membership |60.509s|59.358s|Separate full-frontend screen; 1.90% less, needs confirmation.|

The last three rows compare separate candidate runs with an earlier baseline;
they are **not** fresh paired measurements. Each parser pair has one observation
per image, not a counterbalanced repeated sample. For lookahead, complete process
time including input reads, Base, digest and teardown was 27.247→23.850s
(12.47% less). No filesystem cache flush or statistical confidence claim.

The combined whole-process medians are 71.320→64.684s, 9.30% less; digest cost
remains approximately 8.15s. Frontend observations were 62.624/63.084s versus
56.437/56.001s. Use this fresh paired baseline for the combined result, rather
than the earlier 60.509s screen baseline. Its full candidate source adds 2,175 bytes (0.069%),
three replacements, ten helper definitions and nine forward declaration laws,
with every original declaration,
all 112 protected declarations and the original native main preserved. This is
the separate frontend component measurement, not the complete build timer.
The maintained source grows by 98 lines. The nine laws are forward signatures,
not mathematical proofs or new compiler-correctness theorems.

The complete build comparison uses the same frozen source path, prepared Base,
runtime, QBE/assembler/linker, target flags, resource limits and expected QBE.
Both stream the reference comparison without retaining IR; QBE, assembly and
object identities match. The [33-check receipt audit](evidence/fixed-pair-audit.json)
records these controls. Candidate ran first and baseline second on CPU3; there
was one observation each and no filesystem-cache flush. The 3.56% reduction is
an observed pair, not a confidence interval. The timer includes compiler
execution and machine construction after builder preflight. It does not include
the diagnostic digest used in the frontend experiments.

The earlier candidate-source N1/N2 acquisition comparison showed 4.26% less
time, but its retention/reference policies differ. It is bootstrap evidence,
not the headline performance comparison. The broader result is modest: a
10.56% frontend reduction becomes 3.56% for the complete build. The work outside
the frontend still dominates; this phase has not established a 100-second path.

The frontend driver stops before backend optimization, QBE rendering and machine
construction. Its `parse`, `check`, `context`, `annotation` and `request` modes
are cumulative stopping points, not additive stage timers. The complete request
baseline clocks **60.509s frontend**, 0.213s Base and **8.081s structural
observation**, inside 68.874s complete process time. The parser-only baseline's
observation is about 0.486s. The 32-bit digest is a timing observation, supported
by separate complete-value comparisons; it is not a collision-free oracle.

## The faster experiment loop

Acquiring the first complete frontend diagnostic executable cost 53.474s,
including 37,118,525 QBE bytes. A separately checked parser-only closure excludes
the checker and eraser and costs **25.746s**, with 18,967,097 QBE bytes: 51.85%
less acquisition time. Both sides of the parser comparison use that smaller
service. This is a narrower diagnostic tool, not a faster production compiler.

The diagnostic services, digest and optimization logic are written in Bend.
Host adapters perform authenticated source transport, process control and full
value comparison; they do not implement the compiler transformations.
See [the precise boundaries](../../experiments/phase175/frontend-loop.md).

## Correctness evidence

Every successful candidate API was independently source-checked. Completed
receipts establish the following finite coverage; repeated executions of the
same controls are not additional distinct tests:

| Candidate | Complete observations |
|---|---|
| Lookahead |66 precedence values, 38 parser values, 3 boundary controls, 41,380 finite operator-alphabet strings; 14 sources at parse/request boundaries, 28 stage comparisons.|
| Precedence |Same parser controls;14 sources across five boundaries, 70 stage comparisons.|
| Parser-only service |14 complete parse values agree with the full frontend service; candidate service also passes 14.|
| Field quantities |18 controls, complete emitted term observations, 16 complete request/error comparisons, including real dependent-field and rewrite programs.|
| Report names |15 literal ordered-list cases checked in both APIs, complete cross-API records, 14 request/error comparisons.|
| Publication |45 update observations in each API, literal stale-ADT answers, 7 small and 8 large complete DChecking comparisons, and 6 sources at check/request boundaries.|
| Selected combination |14 sources at parse/request boundaries, 28 complete stage comparisons, with the unchanged request oracle checked for all 14. An earlier three-source transfer run also passed. Isolated finite controls are not counted as rerun combination coverage.|

The ordinary unchanged request entry is also compared where the receipt records
it. Values include constructor variants, all fields, spans, quantities,
ownership metadata, order, indexes and diagnostics. These are finite checks, not
BendTT theorems or whole-compiler equivalence proofs. Matching native digests on
the large timing input supplements these gates. That frontend comparison alone
does not establish full-source complete-value or generated-QBE equality.

Subsequent native gates provide separate evidence: **64/64** focused and broad
correctness cases pass in 67.273s, and **45/45 exact timed-wrapper QBE products**
match the retained references in 54.875s under the same runtime and machine
policy. Those product identities preserve the existing performance evidence for
the exact workloads; they are not a new runtime timing campaign or a full-language
conformance claim. N2 also emits Q3 identical to the candidate N1/N2 QBE in
157.007s native execution (158.254s request total), without machine construction.
See [the native checkpoint](native-checkpoint.md) for acquisition boundaries.

Publication exposed an important fixture mistake: duplicate constructor names
are rejected by the parser, before compact checking. The first comparison
correctly failed its claimed compact-admission gate. An independent probe
established the actual boundary, and the corrected manifest explicitly keeps
that source as a parser-error control. Five other large sources reach compact
checking; direct large DChecking controls retain checker-collision coverage.
The original failure is preserved. The older general fixture named
`erased-param` also remains a parser-negative control, not positive erasure
coverage; the two new well-formed dependent/rewrite fixtures provide that.

Independent [field provenance](../../experiments/phase175/field-provenance-audit.md)
and [report-name](../../experiments/phase175/semantic-report-names.md) audits
remain explicit about scope. Ann marker shape alone is not authority for
erasure. The suspected report-name lone-surrogate exception was falsified by
source and generated-code inspection: both membership equality and hashing use
nonvalidating code-point reads; no extra Unicode guard was added.

## Negative evidence and cost discipline

Eight failed API acquisitions are retained: affine-use mistakes, an attempted IO
`main` export, typed definitions after forward laws, a KLambda pattern arity
mistake, and a reserved `law` local. Subsequent checked acquisitions repair these
without changing the independent semantic gates. One native lookahead acquisition
was stopped by the disk-budget guard during external filesystem consumption;
the later acquisition used fresh output and succeeded.

The first full-candidate CLI check exited with `SOME PROOFS FAIL`: 7,195
definitions depend on unsafe or foreign code. This is the CLI's proof-safety
policy refusal, not a source type failure. It neither qualifies nor refutes the
candidate's source typing. The separate source-only check and native qualification
are distinct gates: `full-source-check02` subsequently passed unmodified upstream
loading, `book_valid` and zero unresolved holes in 7.306s (8.064s guarded wall
time). This establishes source type acceptance, not proof safety, BendTT
verification or backend correctness. The subsequent finite native and exact
product gates above address their respective scopes; the public cross-backend
product gates subsequently passed and the exact selected source is integrated.

Method files evolved during the investigation. Historical receipts retain their
original method hashes; in particular the precedence and field comparison runs
used older `compare-frontends.mjs` versions. Those exact historical bytes are not
claimed to remain at the live path. The report pins the current comparator
`9eff7115e15dd1bfa5db5af56de3083a8a76c2cddcef62c90fd5ea4f627b7ea9`;
new reruns must record that method version and fresh results. Original receipts
are preserved rather than rewritten to appear authenticated by the newer tool.

The same-source upstream C diagnostic emitted 11,871,272 C bytes in 30.256s, then
Clang exceeded its 80-second construction window. It produced no execution-speed
comparison. This is an incomplete diagnostic, not evidence that C runs faster
or slower. Its original zero ABI counts were a regex error; the
[corrected static census](../../experiments/phase175/parser-c-census-correction.json)
finds 43 Term parameters and 7,833 WL_CASE lines. The failed receipt stays unchanged.

The first frozen-source candidate acquisition was refused **before the compiler
started**: a 128 MiB declared disk budget could not fit above the unchanged 5 GiB
reserve. The 112 MiB retry, justified by prior comparable allocation, passed and
used 105.04 MiB in its declared output root. This was resource admission, not a
compiler failure, weakened reserve or timeout.

[Verified storage recovery](../../experiments/phase175/storage-recovery.md)
recovered 3,012.09 MiB net in the emergency tranche, or 3,273.20 MiB including the
earlier already-archived selection. Exact originals were archived and independently
verified before pruning. Installed images, rollback and current evidence stayed
hot; the normal 5 GiB compiler reserve remained unchanged. Later
[own-intermediate recovery and exact deduplication](../../experiments/phase175/storage-followup.md)
are accounted separately. Recovery time, target
time and agent effort must not be conflated. The final
[outer-guard census](cost-census.json) counts 62 closed invocations once each:
2,799.683s (46.66 minutes), including 187.605s failed runs and 4.622s stopped work.
No outer runs remain open. Nested compilation/test-case
timers are never added; storage recovery, unguarded work, agent effort and quota
are outside this total. The recorded outer intervals do not overlap.

## Integration and next decision

The combined frontend gate passed. The full candidate is prepared separately as
`a0e953a84de73aa22403dde7ec2144540197633857a0f7b5b9784f9e66f5ad04`,
with exact inverse reconstruction of the parent and no pruned declarations.
Independent source checking, native64 and the 45 QBE product gates are complete.
Six representative complete JS products and six C products also match the
qualified references exactly; this gate did not rebuild or execute those
programs. Integration reproduces the selected QBE source exactly and preserves
the corresponding native-C, JS-API and policy source profiles. The latest
qualified candidate is `selfhost/build/phase175/full-native-n2/program`; installed
selection remains unchanged. Keep installed promotion a separate decision.
Keep field reuse, extra publication deferral and precedence dispatch out of the
selected combination unless new evidence overturns their neutral screens.
Prioritize the still-dominant post-frontend work for the next performance
investigation. Installation remains a separate qualification decision.

Compact raw reports, resource-guard receipts, selected diagnostics and finite
value artifacts are retained losslessly under [evidence/](evidence/index.json).
The main evidence index links those copies and pins the complete local receipts.
Large source manifests, compiler images and generated products are not duplicated;
the retained evidence is not a standalone executable reproduction capsule.
